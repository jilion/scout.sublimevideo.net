require 'tempfile'

class ScreenshotGrabber

  def initialize(site_token, options = { debug: false, external_log: false })
    @site_token = site_token
    @options    = options
  end

  def take!
    check_memory!
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
      log :info, "Couldn't capture referrer #{url}, will try #{hostname_for_screenshot}" unless take_screenshot!(url, tempfile)
    end

    unless File.size?(tempfile.path)
      url = hostname_for_screenshot
      raise "Couldn't screenshot hostname #{url} (#{@site_token})!" unless take_screenshot!(url, tempfile)
    end

    url
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
      if referrer = Referrer.where(token: @site_token).by_hits.first
        referrer.url =~ %r{wp-content/plugins/sublimevideo-official} ? nil : referrer.url # don't screenshot unaccessible WP page
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

  # Taken from http://stackoverflow.com/questions/8146070/how-to-catch-memory-quota-exceptions-in-a-heroku-worker
  def self.check_memory?
    @@check_memory ||= File.exists?("/proc/self/statm")
  end

  def check_memory!
    return unless self.class.check_memory?

    log :error, "Current memory: #{number_to_human_size(memory)}"
    raise 'AboutToRunOutOfMemory' if memory > 490.megabytes # Or whatever size your worried about
  end

  # Taken from Oink
  def memory
    pages = File.read("/proc/self/statm")
    pages.to_i * self.class.statm_page_size
  end

  def self.statm_page_size
    @@statm_page_size ||= begin
      page_size = `getconf PAGESIZE`
      if $?.success?
        page_size.strip.to_i / 1024
      else
        4
      end
    end
  end

end
