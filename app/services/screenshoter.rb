class Screenshoter

  attr_accessor :token, :reason

  def initialize(args)
    @token  = args[:token]
    @reason = args[:reason]
  end

  def self.take(token, reason)
    new(token: token, reason: reason).take
  end

  def take
    ScreenshotWorker.perform_async(token) if screenshot_possible?
  end

  # Returns whether or not a screenshot can be taken for the given token.
  #
  # @return false if the site screenshoting cannot be retried yet
  # @return false if the site screenshoting has had already too many attempts
  # @return true otherwise
  #
  def screenshot_possible?
    common_checks = !(_valid_screenshoted_site? || _cannot_be_retried_ever? || _cannot_be_retried_yet?)
    specific_checks = (reason != 'activity') || latest_screenshot_is_old_enough?

    common_checks && specific_checks
  end

  # Returns whether a screnshot for a site is old enough so that we can take a new one
  #
  def latest_screenshot_is_old_enough?(date = 5.days.ago)
    screenshoted_site = ScreenshotedSite.where(t: token).first

    screenshoted_site.nil? || screenshoted_site.latest_screenshot_older_than?(date)
  end

  private

  def _valid_screenshoted_site?
    ScreenshotedSite.where(t: token).where(lfa: nil).present?
  end

  def _cannot_be_retried_ever?
    ScreenshotedSite.where(t: token).with_max_attempts.present?
  end

  def _cannot_be_retried_yet?
    (1...ScreenshotedSite::MAX_ATTEMPTS).any? do |n|
      ScreenshotedSite.where(t: token).cannot_be_retried(n).present?
    end
  end

end
