require 'screenshot_grabber'

class ScreenshotWorker
  include Sidekiq::Worker
  sidekiq_options queue: :scout

  # Takes a screenshot of the site with the given token.
  #
  # @param [String] token The token of the site to sreenshot.
  def perform(token)
    # Don't allow more than 2 minutes!
    ScreenshotGrabber.new(token).take!
  end
end
