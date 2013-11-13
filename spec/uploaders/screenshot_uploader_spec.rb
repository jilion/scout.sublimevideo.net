require 'fast_spec_helper'
require 'rails/railtie'
require 'carrierwave'
require 'config/carrierwave'
require 'support/fixtures_helpers'

require 'uploaders/screenshot_uploader'

describe ScreenshotUploader do
  let(:screenshot) { double(id: '0123456789', site: double(t: 'site_token'), u: 'http://sublimevideo.net') }
  let(:image)      { fixture_file('sublimevideo.net.jpg') }
  let(:uploader)   { described_class.new(screenshot, :f) }

  before do
    uploader.store!(image)
  end
  after { uploader.remove! }

  it "is stored in ENV['S3_SCREENSHOTS_BUCKET'] bucket" do
    expect(uploader.fog_directory).to eq ENV['S3_SCREENSHOTS_BUCKET']
  end

  it "is private" do
    expect(uploader.fog_public).to be_falsey
  end

  it "has 'image/jpeg' as content type" do
    expect(uploader.file.content_type).to eq 'image/jpeg'
  end

  it "begins with the model id" do
    expect(uploader.file.filename).to match /\A0123456789\-/
  end

  it "contains the URL parameterized" do
    expect(uploader.file.filename).to match /sublimevideo-net/
  end

  it "has jpg extension" do
    expect(uploader.file.filename).to match /\.jpg\Z/
  end

  describe 'carousel version' do
    describe 'the carousel version' do
      it "resize to fill the image to 1100x825" do
        expect(uploader.carousel).to have_dimensions(1100, 825)
      end
    end
  end

end
