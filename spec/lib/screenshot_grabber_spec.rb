require 'fast_spec_helper'
require 'active_support/core_ext'
require File.expand_path('lib/screenshot_grabber')

describe ScreenshotGrabber do
  before do
    stub_rails
    stub_class 'ScreenshotedSite', 'Screenshot'#, 'Site', 'Referrer'
  end

  let(:screenshot_grabber) { described_class.new(site_token) }
  let(:site_token)         { 'site_token' }
  let(:site)               { stub }
  let(:screenshoted_site)  { stub }
  let(:url)                { 'http://sublimevideo.net' }
  let(:image)              { stub }
  let(:screenshot)         { stub }

  describe '#take!' do
    context 'site is valid for screenshot' do
      before do
        screenshot_grabber.stub(site: site)
        screenshot_grabber.stub(screenshoted_site: screenshoted_site)
        screenshot_grabber.stub(referrer_for_screenshot: url)
        screenshot_grabber.should_receive(:with_tempfile_image).and_yield(image)
      end

      it 'create a Screenshot with the image', :focus do
        Screenshot.should_receive(:create!).with(
          site: screenshoted_site,
          u: url,
          f: image
        )

        screenshot_grabber.take!
      end
    end
  end

  describe '#take_screenshot!' do
    it 'adds the screenshot to the ScreenshotedSite\'s screenshots collection and save it' do
      Phantomjs.should_receive(:run).with(Rails.root.join('lib', 'phantomjs', 'rasterize.js').to_s, url, 'tmp/foo.jpg')

      screenshot_grabber.take_screenshot!(url, stub(path: 'tmp/foo.jpg'))
    end
  end

  describe '#with_tempfile_image' do
    before do
      screenshot_grabber.stub(referrer_for_screenshot: url)
    end

    it 'yield with an url and an image that is not empty' do
      screenshot_grabber.send(:with_tempfile_image) do |img|
        img.size.should > 0
      end
    end
  end

end
