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
      log :info, 'OK!'
    end
  rescue => ex
    log :error, "EX: #{ex.inspect}"
    true # don't retry the work...
  end

  def take_screenshot!(url, file)
    cmd = "phantomjs #{File.expand_path('../phantomjs-scripts/rasterize.js', __FILE__)} #{url} #{file.path}"
    log :info, cmd
    system cmd
  end

  private

  def with_tempfile_image
    tempfile = Tempfile.new(['screenshot', '.jpg'])

    begin
      take_screenshot!(referrer_for_screenshot, tempfile)
      raise "#{tempfile.path} is empty!" unless File.size?(tempfile.path)

      yield(tempfile)
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def site
    @site ||= Site.with_hostname.find_by_token(@site_token)
  end

  def screenshoted_site
    @screenshoted_site ||= ScreenshotedSite.find_or_create_by(t: @site_token)
  end

  def referrer_for_screenshot
    @referrer_for_screenshot ||= if referrer = Referrer.where(token: @site_token).by_hits.first
      referrer.url
    else
      "http://#{site.hostname}"
    end
  end

  def logger
    @logger ||= @options[:external_log] ? Logger.new(File.expand_path('../../log/screenshot_grabber.log', __FILE__)) : Rails.logger
  end

  def log(level, message)
    if level == 'error' || @options[:debug]
      logger.send(level, lambda { "[#{Time.now.utc.strftime("%F %T")}] TOKEN: ##{@site_token} | URL: #{referrer_for_screenshot}\n\t#{message}" })
    end
  end

end
