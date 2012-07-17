require 'fast_spec_helper'
require 'carrierwave'
require File.expand_path('spec/config/carrierwave')
require File.expand_path('app/uploaders/screenshot_uploader')

describe ScreenshotUploader do
  let(:screenshot) { stub(id: '0123456789', site: stub(t: 'site_token'), u: 'http://sublimevideo.net') }
  let(:image)      { fixture_file('sublimevideo.net.jpg') }
  let(:uploader)   { described_class.new(screenshot, :f) }

  before do
    stub_rails
    uploader.store!(image)
  end
  after do
    uploader.remove!
    Dir.delete(Rails.root.join('screenshots'))
  end

  it "is stored in ENV['S3_SCREENSHOTS_BUCKET'] bucket" do
    uploader.fog_directory.should eq ENV['S3_SCREENSHOTS_BUCKET']
  end

  it "is private" do
    uploader.fog_public.should be_false
  end

  it "has 'image/jpeg' as content type" do
    uploader.file.content_type.should eq 'image/jpeg'
  end

  it "begins with a timestamp" do
    uploader.file.filename.should =~ /\A\d{10}\-/
  end

  it "contains the URL parameterized" do
    uploader.file.filename.should =~ /sublimevideo-net/
  end

  it "has jpg extension" do
    uploader.file.filename.should =~ /\.jpg\Z/
  end

  describe 'carousel version' do
    before do
      described_class.enable_processing = true
    end
    after do
      described_class.enable_processing = false
    end

    describe 'the carousel version' do
      it "resize to fill the image to 1100x825" do
        uploader.carousel.should have_dimensions(1100, 825)
      end
    end
  end

end