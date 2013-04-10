require 'spec_helper'

describe ScreenshotedSite do
  let(:attributes) do
    { t: 'site_token' }
  end

  it { should validate_presence_of(:t) }

  it 'validates uniqueness of t' do
    create(:screenshoted_site, attributes)

    expect { described_class.create!(attributes) }.to raise_error
  end

  describe '.cannot_be_retried' do
    before do
      @not_failed         = create(:screenshoted_site, lfa: nil)
      @failed_3_days_ago1 = create(:screenshoted_site, lfa: 3.days.ago, fac: 1)
      @failed_3_days_ago2 = create(:screenshoted_site, lfa: 3.days.ago, fac: 2)
      @failed_today       = create(:screenshoted_site, lfa: Time.now.utc, fac: 1)
    end

    it 'returns site with lfa >= (calculated date from given attempts count)' do
      described_class.cannot_be_retried(1).entries.should eq [@failed_today]
      described_class.cannot_be_retried(2).entries.should eq [@failed_3_days_ago2]
    end
  end

  describe '.with_max_attempts' do
    before do
      ScreenshotedSite::MAX_ATTEMPTS = 5 unless defined? ScreenshotedSite::MAX_ATTEMPTS
      @failed0 = create(:screenshoted_site, fac: 0)
      @failed1 = create(:screenshoted_site, fac: 1)
      @failed5 = create(:screenshoted_site, fac: 5)
      @failed6 = create(:screenshoted_site, fac: 6)
    end

    it 'returns site with failed attempts >= max attempts' do
      described_class.with_max_attempts.entries.should eq [@failed5, @failed6]
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
