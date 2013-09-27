require 'fast_spec_helper'
require 'sidekiq'

require File.expand_path('app/workers/screenshot_worker')

describe ScreenshotWorker do
  stub_class 'ScreenshotGrabber'

  let(:worker)             { described_class.new }
  let(:site_token)         { 'site_token' }
  let(:screenshot_grabber) { double }

  describe '#perform' do
    it 'instantiates a ScreenshotGrabber and calls take! on it' do
      expect(ScreenshotGrabber).to receive(:new).with(site_token) { screenshot_grabber }
      expect(screenshot_grabber).to receive(:take!)

      worker.perform(site_token)
    end
  end

end
