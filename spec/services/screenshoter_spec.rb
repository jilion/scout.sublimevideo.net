require 'spec_helper'

describe Screenshoter do

  describe '#screenshot_possible?' do
    before do
      @screenshotable = 4.times.inject([]) do |memo, i|
        memo << create(:screenshoted_site, fac: i+1, lfa: ScreenshotedSite::DELAY.call(i+1).days.ago)
        memo
      end
      @not_screenshotable = 4.times.inject([]) do |memo, i|
        memo << create(:screenshoted_site, fac: i+1, lfa: ScreenshotedSite::DELAY.call(i+1).days.ago + 1)
        memo
      end
      @not_screenshotable << create(:screenshoted_site, fac: 0)
      @not_screenshotable << create(:screenshoted_site, fac: ScreenshotedSite::MAX_ATTEMPTS)
    end

    it "is screenshotable" do
      @screenshotable.each do |screenshoted_site|
        described_class.new(token: screenshoted_site.t).should be_screenshot_possible
      end
      described_class.new(token: 'foo').should be_screenshot_possible
    end

    it "is not screenshotable" do
      @not_screenshotable.each do |screenshoted_site|
        described_class.new(token: screenshoted_site.t).should_not be_screenshot_possible
      end
    end
  end

  describe '#latest_screenshot_is_old_enough?' do
    let(:screenshot) { create(:screenshot, created_at: 3.days.ago) }

    it { described_class.new(token: screenshot.site.t).latest_screenshot_is_old_enough?(5.days.ago).should be_false }
    it { described_class.new(token: screenshot.site.t).latest_screenshot_is_old_enough?(2.days.ago).should be_true }
  end

end