require 'tempfile'
require 'phantomjs.rb'

class ScreenshotGrabber

  def initialize(site_token)
    @site_token = site_token
    @logger = Logger.new(File.expand_path('../../log/screenshot_grabber.log', __FILE__))
  end

  def take!
    return unless site

    with_tempfile_image do |image|
      Screenshot.create!(site: screenshoted_site, u: referrer_for_screenshot, f: image)
      @logger.info { "[#{Time.now.utc.strftime("%F %T")}] TOKEN: ##{@site_token}, URL: #{referrer_for_screenshot}, OK!" }
    end
  rescue => ex
    @logger.info { "[#{Time.now.utc.strftime("%F %T")}] TOKEN: ##{@site_token}, URL: #{referrer_for_screenshot}, EX: #{ex.inspect}" }
    true # don't retry the work...
  end

  def take_screenshot!(url, file)
    Phantomjs.run(File.expand_path('../phantomjs/rasterize.js', __FILE__), url, file.path)
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

end
