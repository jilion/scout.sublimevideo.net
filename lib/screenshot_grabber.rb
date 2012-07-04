require 'tempfile'

class ScreenshotGrabber

  def initialize(site_token, options = { debug: false, external_log: false })
    @site_token = site_token
    @options = options
  end

  def take!
    return unless site

    with_tempfile_image do |image|
      Screenshot.create!(site: screenshoted_site, u: referrer_for_screenshot, f: image)
      screenshoted_site.set(:lfa, nil) unless screenshoted_site.lfa.nil?
    end
  rescue => ex
    screenshoted_site.set(:lfa, Time.now.utc)
    log :error, "EX: #{ex.inspect}"
    true # don't retry the work...
  end

  private

  def with_tempfile_image
    begin
      tempfile = Tempfile.new(['screenshot', '.jpg'])
      success = screenshot_referrer_or_hostname(tempfile)

      raise "Screenshot for #{referrer_for_screenshot} (#{@site_token}) was not successful!" unless success
      raise "#{tempfile.path} is empty!" unless File.size?(tempfile.path)

      yield(tempfile)
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def screenshot_referrer_or_hostname(tempfile)
    success = false
    if referrer_for_screenshot
      success = take_screenshot!(referrer_for_screenshot, tempfile)
      Rails.logger.info "Couldn't screenshot referrer #{referrer_for_screenshot}, will try with #{hostname_for_screenshot} instead." unless success
    end
    success = take_screenshot!(hostname_for_screenshot, tempfile) unless success

    success
  end

  def take_screenshot!(url, file)
    cmd = "phantomjs --ignore-ssl-errors=yes #{File.expand_path('../phantomjs-scripts/rasterize.js', __FILE__)} #{url} #{file.path}"
    log :info, cmd
    system cmd
  end

  def site
    @site ||= Site.with_hostname.find_by_token(@site_token)
  end

  def screenshoted_site
    @screenshoted_site ||= ScreenshotedSite.find_or_create_by(t: @site_token)
  end

  def referrer_for_screenshot
    @referrer_for_screenshot ||= begin
      referrer.url if referrer = Referrer.where(token: @site_token).by_hits.first
    end
  end

  def hostname_for_screenshot
    "http://#{site.hostname}"
  end

  def logger
    @logger ||= @options[:external_log] ? Logger.new(File.expand_path('../../log/screenshot_grabber.log', __FILE__)) : Rails.logger
  end

  def log(level, message)
    if level == 'error' || @options[:debug]
      logger.send(level, "[#{Time.now.utc.strftime("%F %T")}] TOKEN: ##{@site_token} | URL: #{referrer_for_screenshot}\n\t#{message}")
    end
  end

end
