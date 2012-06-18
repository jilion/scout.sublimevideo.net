require 'screenshot_grabber'

class ScreenshotWorker
  include Sidekiq::Worker

  # Takes a screenshot of the site with the given token.
  #
  # @param [String] token The token of the site to sreenshot.
  def perform(token)
    ScreenshotGrabber.new(token).take!
  end
end
