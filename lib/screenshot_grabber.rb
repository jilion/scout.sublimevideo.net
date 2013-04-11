require 'tempfile'

class ScreenshotGrabber

  SKIPPED_DOMAINS = [
    /localhost/, /127\.0\.0\.1/,
    %r{wp-content/plugins/sublimevideo-official}
  ]

  def initialize(site_token, options = { debug: false, external_log: false })
    @site_token = site_token
    @options    = options
  end

  def take!
    return unless site

    with_tempfile_image do |url, image|
      Screenshot.create!(site: screenshoted_site, u: url, f: image)
      screenshoted_site.set(:lfa, nil)
      screenshoted_site.set(:fac, 0)
    end
  rescue => ex
    screenshoted_site.touch(:lfa)
    screenshoted_site.inc(:fac, 1)
    log :error, "EX: #{ex.inspect}"
    true # don't retry the work...
  end

  private

  def with_tempfile_image
    begin
      tempfile = Tempfile.new(['screenshot', '.jpg'])
      screenshoted_url = screenshot_referrer_or_hostname(tempfile)

      yield(screenshoted_url, tempfile)
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def screenshot_referrer_or_hostname(tempfile)
    url = screenshot_referrer(tempfile)
    url = screenshot_hostname!(tempfile) unless File.size?(tempfile.path)

    url
  end

  def screenshot_referrer(tempfile)
    if url = referrer_for_screenshot
      unless take_screenshot!(url, tempfile)
        handle_screenshot_process_exit_status($?.exitstatus, url: url) if $?
      end

      url
    end
  end

  def screenshot_hostname!(tempfile)
    url = hostname_for_screenshot
    unless take_screenshot!(url, tempfile)
      handle_screenshot_process_exit_status!($?.exitstatus, url: url) if $?
    end

    url
  end

  def take_screenshot!(url, file)
    cmd = %w[phantomjs --ignore-ssl-errors=yes]
    cmd << File.expand_path('../phantomjs-scripts/rasterize.js', __FILE__)
    cmd << url << file.path << site.safe_status
    cmd = cmd.join(' ')

    log :info, cmd
    system cmd
  end

  def handle_screenshot_process_exit_status(exit_status, options = {})
    options = { raise: false }.merge(options)

    case exit_status
    when 1
      msg = "Couldn't screenshot: #{options[:url]} (#{@site_token})"
      if options[:raise]
        raise msg
      else
        log :info, msg
      end
    when 2
      tag_adult_and_raise
    end
  end

  def handle_screenshot_process_exit_status!(exit_status, options = {})
    handle_screenshot_process_exit_status(exit_status, options.merge(raise: true))
  end

  def tag_adult_and_raise
    site.add_tag('adult')
    raise "Porn site tagged: (#{@site_token})!"
  end

  def site
    @site ||= Site.find(@site_token)
  end

  def screenshoted_site
    @screenshoted_site ||= ScreenshotedSite.find_or_create_by(t: @site_token)
  end

  def referrer_for_screenshot
    @referrer_for_screenshot ||= begin
      if referrer = Referrer.by_hits_for(@site_token).first
        case referrer.url
        # don't screenshot unaccessible WP page nor local domains and huge/common domains
        when *(Site::SKIPPED_DOMAINS.map { |domain| Regexp.new(Regexp.escape(domain)) } + SKIPPED_DOMAINS)
          nil
        else
          referrer.url
        end
      end
    end
  end

  def hostname_for_screenshot
    "http://#{site.hostname}"
  end

  def logger
    @logger ||= if @options[:external_log]
      Logger.new(File.expand_path('../../log/screenshot_grabber.log', __FILE__))
    else
      Rails.logger if Rails.respond_to?(:logger)
    end
  end

  def log(level, message)
    if logger && (level == :error || @options[:debug])
      logger.send(level, "[#{Time.now.utc.strftime("%F %T")}] TOKEN: ##{@site_token}\n\t#{message}")
    end
  end

end
