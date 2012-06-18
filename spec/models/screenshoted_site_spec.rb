require 'spec_helper'

describe ScreenshotedSite, :focus do
  let(:attributes) do
    { t: 'site_token' }
  end

  it { should validate_presence_of(:t) }

  it 'validates uniqueness of t' do
    create(:screenshoted_site, attributes)

    expect { described_class.create!(attributes) }.to raise_error
  end

  describe '#latest_screenshot_older_than' do
    let(:latest_screenshot) { create(:screenshot, created_at: 2.days.ago) }
    let(:attributes) do
      { t: 'site_token', screenshots: [latest_screenshot] }
    end
    let(:screenshoted_site) { create(:screenshoted_site, attributes) }

    it { screenshoted_site.latest_screenshot_older_than(1).should be_true }
    it { screenshoted_site.latest_screenshot_older_than(5).should be_false }
  end
end
