require 'fast_spec_helper'
require 'rails/railtie'
require 'carrierwave'
require 'config/carrierwave'
require 'support/fixtures_helpers'

require 'uploaders/screenshot_uploader'

describe ScreenshotUploader do
  let(:screenshot) { stub(id: '0123456789', site: stub(t: 'site_token'), u: 'http://sublimevideo.net') }
  let(:image)      { fixture_file('sublimevideo.net.jpg') }
  let(:uploader)   { described_class.new(screenshot, :f) }

  before do
    uploader.store!(image)
  end
  after { uploader.remove! }

  it "is stored in ENV['S3_SCREENSHOTS_BUCKET'] bucket" do
    uploader.fog_directory.should eq ENV['S3_SCREENSHOTS_BUCKET']
  end

  it "is private" do
    uploader.fog_public.should be_false
  end

  it "has 'image/jpeg' as content type" do
    uploader.file.content_type.should eq 'image/jpeg'
  end

  it "begins with the model id" do
    uploader.file.filename.should =~ /\A0123456789\-/
  end

  it "contains the URL parameterized" do
    uploader.file.filename.should =~ /sublimevideo-net/
  end

  it "has jpg extension" do
    uploader.file.filename.should =~ /\.jpg\Z/
  end

  describe 'carousel version' do
    describe 'the carousel version' do
      it "resize to fill the image to 1100x825" do
        uploader.carousel.should have_dimensions(1100, 825)
      end
    end
  end

end
