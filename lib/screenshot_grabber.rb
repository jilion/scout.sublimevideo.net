require 'tempfile'
require 'action_view/helpers/number_helper'

class ScreenshotGrabber
  include ActionView::Helpers::NumberHelper

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
    url = nil

    if url = referrer_for_screenshot
      take_screenshot!(url, tempfile)
      case $?
      when 1
        log :info, "Couldn't screenshot referrer: #{url} (#{@site_token})"
      when 666
        tag_adult_and_raise
      end
    end

    unless File.size?(tempfile.path)
      url = hostname_for_screenshot
      take_screenshot!(url, tempfile)
      case $?
      when 1
        raise "Couldn't screenshot hostname: #{url} (#{@site_token})"
      when 666
        tag_adult_and_raise
      end
    end

    url
  end

  def take_screenshot!(url, file)
    cmd = "phantomjs --ignore-ssl-errors=yes #{File.expand_path('../phantomjs-scripts/rasterize.js', __FILE__)} #{url} #{file.path}"
    log :info, cmd
    system cmd
  end

  def tag_adult_and_raise
    site.tags << 'adult'
    site.save
    raise "Porn site detected: #{url} (#{@site_token})!"
  end

  def site
    @site ||= Site.with_hostname.find_by_token(@site_token)
  end

  def screenshoted_site
    @screenshoted_site ||= ScreenshotedSite.find_or_create_by(t: @site_token)
  end

  def referrer_for_screenshot
    @referrer_for_screenshot ||= begin
      if referrer = Referrer.where(token: @site_token).by_hits.first
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
    @logger ||= @options[:external_log] ? Logger.new(File.expand_path('../../log/screenshot_grabber.log', __FILE__)) : Rails.logger
  end

  def log(level, message)
    if level == :error || @options[:debug]
      logger.send(level, "[#{Time.now.utc.strftime("%F %T")}] TOKEN: ##{@site_token}\n\t#{message}")
    end
  end

end
