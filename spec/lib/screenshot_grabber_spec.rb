require 'fast_spec_helper'
require 'active_support/core_ext'
require File.expand_path('lib/screenshot_grabber')

Site = Class.new unless defined? Site
Site::SKIPPED_DOMAINS = %w[please-edit.me youtube.com youtu.be vimeo.com dailymotion.com google.com] unless defined? Site::SKIPPED_DOMAINS

describe ScreenshotGrabber do
  let(:screenshot_grabber) { described_class.new(site_token) }
  let(:site_token)         { 'site_token' }
  let(:site)               { stub(safe_status: 'safe') }
  let(:screenshoted_site)  { stub(lfa: nil) }
  let(:referrer_url)       { 'http://google.com' }
  let(:hostname_url)       { 'http://sublimevideo.net' }
  let(:image)              { stub }
  let(:screenshot)         { stub }
  let(:tempfile)           { stub(path: 'tmp/foo.jpg') }

  before do
    stub_rails
    stub_class 'ScreenshotedSite', 'Screenshot', 'Site', 'Referrer'
    Site.stub(:find).with('site_token') { site }
  end

  describe '#take!' do
    context 'site is valid for screenshot' do
      before do
        screenshot_grabber.stub(site: site)
        screenshot_grabber.stub(screenshoted_site: screenshoted_site)
        screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
      end

      it 'creates a Screenshot with the image, sets :lfa field to nil and :fac field to 0' do
        screenshot_grabber.should_receive(:with_tempfile_image).and_yield(referrer_url, image)
        Screenshot.should_receive(:create!).with(
          site: screenshoted_site,
          u: referrer_url,
          f: image
        )
        screenshoted_site.should_receive(:set).with(:lfa, nil).ordered
        screenshoted_site.should_receive(:set).with(:fac, 0).ordered

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
        screenshot_grabber.should_receive(:with_tempfile_image) { raise RuntimeError }
        Screenshot.should_not_receive(:create!)
        screenshoted_site.should_receive(:touch).with(:lfa)
        screenshoted_site.should_receive(:inc).with(:fac, 1)

        screenshot_grabber.take!
      end
    end
  end

  # Private methods
  #################

  describe '#take_screenshot!' do
    it 'adds the screenshot to the ScreenshotedSite\'s screenshots collection and save it' do
      screenshot_grabber.should_receive(:system).with("phantomjs --ignore-ssl-errors=yes #{Rails.root.join('lib', 'phantomjs-scripts', 'rasterize.js').to_s} #{referrer_url} tmp/foo.jpg safe")

      screenshot_grabber.send(:take_screenshot!, referrer_url, tempfile)
    end
  end

  describe '#with_tempfile_image' do
    before do
      screenshot_grabber.stub(referrer_for_screenshot: referrer_url)
    end

    it 'yield with an url and an image that is not empty' do
      screenshot_grabber.send(:with_tempfile_image) do |url, img|
        url.should eq referrer_url
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
          File.should_receive(:size?).with(tempfile.path).and_return(true)
        end

        it 'takes a screenshot using the referrer' do
          screenshot_grabber.send(:screenshot_referrer_or_hostname, tempfile).should eq referrer_url
        end
      end

      context 'screenshot with referrer is unsuccessful, but successful with hostname' do
        before do
          screenshot_grabber.should_receive(:take_screenshot!).with(referrer_url, tempfile).and_return(false)
          File.should_receive(:size?).with(tempfile.path).and_return(false)
          screenshot_grabber.should_receive(:take_screenshot!).with(hostname_url, tempfile).and_return(true)
        end

        it 'takes a screenshot using the referrer' do
          screenshot_grabber.send(:screenshot_referrer_or_hostname, tempfile).should eq hostname_url
        end
      end
    end
  end

  describe '#referrer_for_screenshot' do
    context 'referrer is a WP plugin path' do
      before do
        ::Referrer.stub_chain(:where, :by_hits, :first).and_return(stub(url: 'http://mydomain.com/wp-content/plugins/sublimevideo-official/blabla.php'))
      end

      it 'returns nil' do
        screenshot_grabber.send(:referrer_for_screenshot).should be_nil
      end
    end

    Site::SKIPPED_DOMAINS.each do |domain|
      context "referrer is #{domain}" do
        before do
          ::Referrer.stub_chain(:where, :by_hits, :first).and_return(stub(url: "http://#{domain}"))
        end

        it 'returns nil' do
          screenshot_grabber.send(:referrer_for_screenshot).should be_nil
        end
      end
    end
  end

end
