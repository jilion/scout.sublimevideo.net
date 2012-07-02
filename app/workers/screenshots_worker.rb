class ScreenshotsWorker
  include Sidekiq::Worker

  # Delays 'initial' and 'activity' screenshots jobs.
  # @see #take_initial_screenshots
  # @see #take_activity_screenshots
  def perform
    take_initial_screenshots
    take_activity_screenshots
  end

  # Delays screenshot jobs for sites that don't have any
  # screenshot yet.
  def take_initial_screenshots
    tokens_to_initially_screenshot do |token|
      ScreenshotWorker.perform_async(token)
    end
  end

  # Delays screenshot jobs for sites with more than a given
  # threshold of video plays and for which the latest screenshot is older
  # than a given days interval.
  #
  # @param [Hash] opts
  # @option opts [Fixnum] plays_threshold Threshold of video plays that
  #  a site must have in order to be screenshoted.
  # @option opts [Fixnum] days_interval Days interval between two
  #  screenshots.
  # @see #take_initial_screenshots
  def take_activity_screenshots
    tokens_to_activity_screenshot do |token|
      ScreenshotWorker.perform_async(token)
    end
  end

  private

  # Yields the tokens of sites that are eligible for an 'initial' screenshot.
  #
  # @param [Symbol, String] group_iterator A group iterator method name to
  #  iterate over the sites by batch. Useful for testing.
  # @see #take_initial_screenshots
  def tokens_to_initially_screenshot(group_iterator = :find_in_batches, opts = { days_interval: 10.days.ago })
    tokens_to_not_screenshot = ScreenshotedSite.not_failed_or_failed_after(opts[:days_interval]).map(&:t)
    Site.active.with_hostname.send(group_iterator) do |sites_group|
      (sites_group.map(&:token) - tokens_to_not_screenshot).each { |token| yield token }
    end
  end

  # Yields the tokens of sites that are eligible for an 'activity' screenshot.
  #
  # @param [Symbol, String] group_iterator A group iterator method name to
  #  iterate over the sites by batch. Useful for testing.
  # @see #take_initial_screenshots
  def tokens_to_activity_screenshot(group_iterator = :find_in_batches, opts = { plays_threshold: 10, days_interval: 5.days.ago })
    Site.active.with_hostname.with_min_billable_video_views(opts[:plays_threshold]).send(group_iterator) do |sites_group|
      ScreenshotedSite.where(t: sites_group.map(&:token)).each do |screenshoted_site|
        yield(screenshoted_site.t) if screenshoted_site.latest_screenshot_older_than(opts[:days_interval])
      end
    end
  end

end
