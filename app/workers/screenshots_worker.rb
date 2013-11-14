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
  def self.take_initial_screenshots
    Site.find_each(select: %w[token], created_after: _seven_days_ago) do |site|
      Screenshoter.delay(queue: 'scout').take(site.token, 'initial')
    end
  rescue MultiJson::LoadError
  end

  # Delays screenshot jobs for sites with more than a given
  # threshold of video plays and for which the latest screenshot is older
  # than a given days interval.
  #
  def self.take_activity_screenshots
    Site.find_each(select: %w[token], with_min_admin_starts: 10) do |site|
      Screenshoter.delay(queue: 'scout').take(site.token, 'activity')
    end
  end

  private

  def self._seven_days_ago
    Time.now.utc - 3600*24*7
  end

end
