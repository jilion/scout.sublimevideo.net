class ScreenshotsWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'scout'

  # Delays 'initial' and 'activity' screenshots jobs.
  #
  # @see #take_initial_screenshots
  # @see #take_activity_screenshots
  #
  def perform
    self.class.delay(queue: 'scout').take_initial_screenshots
    self.class.delay(queue: 'scout').take_activity_screenshots
  end

  # Delays screenshot jobs for sites that don't have any
  # screenshot yet.
  #
  def take_initial_screenshots
    _sites_to_initially_screenshot.each do |site|
      ScreenshotWorker.perform_async(site.token)
    end
  end

  # Delays screenshot jobs for sites with more than a given
  # threshold of video plays and for which the latest screenshot is older
  # than a given days interval.
  #
  def take_activity_screenshots
    _sites_to_activity_screenshot.each do |site|
      ScreenshotWorker.perform_async(site.token)
    end
  end

  private

  # Returns the tokens of sites that are eligible for an 'initial' screenshot.
  #
  # @see #take_initial_screenshots
  #
  def _sites_to_initially_screenshot
    sites = []
    Site.find_each(select: %w[token], with_state: 'active') do |site|
      sites << site unless _tokens_to_not_screenshot.include?(site.token)
    end

    sites
  end

  # Returns the tokens of sites that are eligible for an 'activity' screenshot.
  #
  # @param [Hash] opts
  # @option opts [Fixnum] plays_threshold Threshold of video plays that
  #  a site must have in order to be screenshoted.
  # @option opts [Fixnum] days_interval Days interval between two
  #  screenshots.
  #
  # @see #take_activity_screenshots
  #
  def _sites_to_activity_screenshot
    options = { plays_threshold: 10, days_interval: 5 }

    sites = []
    Site.find_each(select: %w[token], with_state: 'active', with_min_billable_video_views: options[:plays_threshold]) do |site|
      sites << site if ScreenshotedSite.where(t: site.token).first.latest_screenshot_older_than(options[:days_interval])
    end

    sites
  end

  # Returns the token to not screenshot either because:
  # - the screenshoted site has never had a failed screenshot attempt
  # - the screenshoted site has at least 1 failed attempt and cannot be retried
  #   yet (see logic in ScreenshotedSite)
  # - the screenshoted site has reached the max screenshots attempts
  #
  def _tokens_to_not_screenshot
    @tokens_to_not_screenshot ||= begin
      tokens = ScreenshotedSite.where(lfa: nil).map(&:t)
      (1...ScreenshotedSite::MAX_ATTEMPTS).each do |n|
        tokens += ScreenshotedSite.cannot_be_retried(n).map(&:t)
      end
      tokens += ScreenshotedSite.with_max_attempts.map(&:t)
    end
  end

end
