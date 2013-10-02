require 'fast_spec_helper'
require 'active_support/core_ext'
require File.expand_path('lib/screenshot_grabber')

Site = Class.new unless defined? Site
Site::SKIPPED_DOMAINS = %w[please-edit.me youtube.com youtu.be vimeo.com dailymotion.com google.com] unless defined? Site::SKIPPED_DOMAINS

describe ScreenshotGrabber do
  let(:screenshot_grabber) { described_class.new(site_token) }
  let(:site_token)         { 'site_token' }
  let(:site)               { double(safe_status: 'safe') }
  let(:screenshoted_site)  { double(lfa: nil) }
  let(:referrer_url)       { 'http://google.com' }
  let(:hostname_url)       { 'http://sublimevideo.net' }
  let(:image)              { double('image') }
  let(:screenshots)        { double('screenshots') }
  let(:screenshot)         { double('screenshot') }
  let(:tempfile)           { double(path: 'tmp/foo.jpg') }

  before do
    stub_class 'ScreenshotedSite', 'Screenshot', 'Site', 'SiteStatAdmin'
    Site.stub(:find).with('site_token') { site }
  end

  describe '#take!' do
    context 'site is valid for screenshot' do
      before do
        screenshot_grabber.stub(:site) { site }
        screenshot_grabber.stub(:screenshoted_site) { screenshoted_site }
        expect(screenshot_grabber).to receive(:with_tempfile_image).and_yield(referrer_url, image)
        expect(screenshoted_site).to receive(:screenshots) { screenshots }
      end

      it 'creates a Screenshot with the image, sets :lfa field to nil and :fac field to 0' do
        expect(Screenshot).to receive(:new).with(u: referrer_url, f: image) { screenshot }
        expect(screenshots).to receive(:<<).with(screenshot)
        expect(screenshoted_site).to receive(:update_attributes!).with(lfa: nil, fac: 0)

        screenshot_grabber.take!
      end
    end

    context 'site screenshoting raises an exception' do
      before do
        screenshot_grabber.stub(site: site)
        screenshot_grabber.stub(screenshoted_site: screenshoted_site)
        screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
      end

      it 'sets the :lfa field to the ScreenshotedSite' do
        expect(screenshot_grabber).to receive(:with_tempfile_image) { raise RuntimeError }
        expect(Screenshot).to_not receive(:create!)
        expect(screenshoted_site).to receive(:touch).with(:lfa)
        expect(screenshoted_site).to receive(:inc).with(fac: 1)

        screenshot_grabber.take!
      end
    end
  end

  # Private methods
  #################

  describe '#take_screenshot!' do
    it 'adds the screenshot to the ScreenshotedSite\'s screenshots collection and save it' do
      expect(screenshot_grabber).to receive(:system).with("phantomjs --ignore-ssl-errors=yes #{Rails.root.join('lib', 'phantomjs-scripts', 'rasterize.js').to_s} #{referrer_url} tmp/foo.jpg safe")

      screenshot_grabber.send(:take_screenshot!, referrer_url, tempfile)
    end
  end

  describe '#with_tempfile_image' do
    before do
      screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
    end

    it 'yield with an url and an image that is not empty' do
      screenshot_grabber.send(:with_tempfile_image) do |url, img|
        expect(url).to eq referrer_url
        expect(img.size).to be > 0
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
          expect(screenshot_grabber).to receive(:take_screenshot!).with(referrer_url, tempfile).and_return(true)
          expect(File).to receive(:size?).with(tempfile.path).and_return(true)
        end

        it 'takes a screenshot using the referrer' do
          expect(screenshot_grabber.send(:screenshot_referrer_or_hostname, tempfile)).to eq referrer_url
        end
      end

      context 'screenshot with referrer is unsuccessful, but successful with hostname' do
        before do
          expect(screenshot_grabber).to receive(:take_screenshot!).with(referrer_url, tempfile).and_return(false)
          expect(File).to receive(:size?).with(tempfile.path).and_return(false)
          expect(screenshot_grabber).to receive(:take_screenshot!).with(hostname_url, tempfile).and_return(true)
        end

        it 'takes a screenshot using the referrer' do
          expect(screenshot_grabber.send(:screenshot_referrer_or_hostname, tempfile)).to eq hostname_url
        end
      end
    end
  end

  describe '#referrer_for_screenshot' do
    context 'referrer is a WP plugin path' do
      before do
        ::SiteStatAdmin.stub_chain(:by_hits_for, :first).and_return('http://mydomain.com/wp-content/plugins/sublimevideo-official/blabla.php')
      end

      it 'returns nil' do
        expect(screenshot_grabber.send(:referrer_for_screenshot)).to be_nil
      end
    end

    Site::SKIPPED_DOMAINS.each do |domain|
      context "referrer is #{domain}" do
        before do
          ::SiteStatAdmin.stub_chain(:by_hits_for, :first).and_return("http://#{domain}")
        end

        it 'returns nil' do
          expect(screenshot_grabber.send(:referrer_for_screenshot)).to be_nil
        end
      end
    end
  end

end
