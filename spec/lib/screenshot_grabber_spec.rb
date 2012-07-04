require 'fast_spec_helper'
require 'active_support/core_ext'
require File.expand_path('lib/screenshot_grabber')

describe ScreenshotGrabber do
  before do
    stub_rails
    stub_class 'ScreenshotedSite', 'Screenshot', 'Site'
    screenshot_grabber.stub(logger: '')
  end

  let(:screenshot_grabber) { described_class.new(site_token) }
  let(:site_token)         { 'site_token' }
  let(:site)               { stub }
  let(:screenshoted_site)  { stub(lfa: nil) }
  let(:referrer_url)       { 'http://google.com' }
  let(:hostname_url)       { 'http://sublimevideo.net' }
  let(:image)              { stub }
  let(:screenshot)         { stub }
  let(:tempfile)           { stub(path: 'tmp/foo.jpg') }

  describe '#take!' do
    context 'site is valid for screenshot' do
      before do
        screenshot_grabber.stub(site: site)
        screenshot_grabber.stub(screenshoted_site: screenshoted_site)
        screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
      end

      it 'creates a Screenshot with the image' do
        screenshot_grabber.should_receive(:with_tempfile_image).and_yield(image)
        Screenshot.should_receive(:create!).with(
          site: screenshoted_site,
          u: referrer_url,
          f: image
        )
        screenshoted_site.should_not_receive(:update_attribute)

        screenshot_grabber.take!
      end

      context 'ScreenshotedSite :lfa field is not nil' do
        before do
          screenshoted_site.stub(lfa: Time.now.utc)
        end

        it 'updates ScreenshotedSite :lfa field  to nil' do
          screenshot_grabber.should_receive(:with_tempfile_image).and_yield(image)
          Screenshot.should_receive(:create!).with(
            site: screenshoted_site,
            u: referrer_url,
            f: image
          )
          screenshoted_site.should_receive(:update_attribute).with(:lfa, nil)

          screenshot_grabber.take!
        end
      end
    end

    context 'site screenshoting raises an exception' do
      before do
        screenshot_grabber.stub(site: site)
        screenshot_grabber.stub(screenshoted_site: screenshoted_site)
        screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
      end

      it 'sets the :lfa field to the ScreenshotedSite' do
        screenshot_grabber.should_receive(:with_tempfile_image) { raise RuntimeError }
        Screenshot.should_not_receive(:create!)
        screenshoted_site.should_receive(:update_attribute).with(:lfa, anything)

        screenshot_grabber.take!
      end
    end
  end

  describe '#take_screenshot!' do
    it 'adds the screenshot to the ScreenshotedSite\'s screenshots collection and save it' do
      screenshot_grabber.should_receive(:system).with("phantomjs --ignore-ssl-errors=yes #{Rails.root.join('lib', 'phantomjs-scripts', 'rasterize.js').to_s} #{referrer_url} tmp/foo.jpg")

      screenshot_grabber.send(:take_screenshot!, referrer_url, tempfile)
    end
  end

  describe '#with_tempfile_image' do
    before do
      screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
    end

    it 'yield with an url and an image that is not empty' do
      screenshot_grabber.send(:with_tempfile_image) do |img|
        img.size.should > 0
      end
    end
  end

  describe '#screenshot_referrer_or_hostname' do
    context 'referrer exists' do
      before do
        screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
        screenshot_grabber.stub(hostname_for_screenshot: hostname_url)
      end

      context 'screenshot is successful' do
        before do
          screenshot_grabber.should_receive(:take_screenshot!).with(referrer_url, tempfile).and_return(true)
        end

        it 'takes a screenshot using the referrer' do
          screenshot_grabber.send(:screenshot_referrer_or_hostname, tempfile).should be_true
        end
      end

      context 'screenshot with referrer is unsuccessful, but successful with hostname' do
        before do
          screenshot_grabber.should_receive(:take_screenshot!).with(referrer_url, tempfile).and_return(false)
          screenshot_grabber.should_receive(:take_screenshot!).with(hostname_url, tempfile).and_return(true)
        end

        it 'takes a screenshot using the referrer' do
          screenshot_grabber.send(:screenshot_referrer_or_hostname, tempfile).should be_true
        end
      end
    end
  end

end
