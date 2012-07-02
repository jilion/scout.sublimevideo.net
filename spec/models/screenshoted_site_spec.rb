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

  describe '.not_failed_or_failed_after' do
    before do
      @not_failed        = create(:screenshoted_site, lfa: nil)
      @failed_3_days_ago = create(:screenshoted_site, lfa: 3.days.ago)
      @failed_today      = create(:screenshoted_site, lfa: Time.now.utc)
    end

    it 'returns site with lfa == nil or lfa < given date' do
      described_class.not_failed_or_failed_after(2.days.ago).entries.should eq [@not_failed, @failed_today]
    end
  end

  describe '#latest_screenshot_older_than' do
    let(:latest_screenshot) { create(:screenshot, created_at: 2.days.ago) }
    let(:attributes) do
      { t: 'site_token', screenshots: [latest_screenshot] }
    end
    let(:screenshoted_site) { create(:screenshoted_site, attributes) }

    it { screenshoted_site.latest_screenshot_older_than(1.day.ago).should be_true }
    it { screenshoted_site.latest_screenshot_older_than(5.days.ago).should be_false }
  end
end
