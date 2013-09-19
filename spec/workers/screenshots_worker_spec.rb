require 'fast_spec_helper'
require 'sidekiq'
require 'sidekiq/testing'

require File.expand_path('app/workers/screenshots_worker')

describe ScreenshotsWorker do
  stub_class 'Site', 'Screenshoter'

  let(:worker)      { described_class.new }
  let(:site_token1) { 'site_token1' }
  let(:site_token2) { 'site_token1' }
  let(:site1)       { double(token: site_token1) }
  let(:site2)       { double(token: site_token2) }
  let(:delay_stub)  { double('delay') }

  describe '#perform' do
    it 'calls #take_initial_screenshots, #take_activity_screenshots and #delay_itself' do
      expect(described_class).to receive(:delay) { delay_stub }
      expect(delay_stub).to receive(:take_initial_screenshots)
      expect(described_class).to receive(:delay) { delay_stub }
      expect(delay_stub).to receive(:take_activity_screenshots)

      worker.perform
    end
  end

  describe '.take_initial_screenshots' do
    it 'enqueues a screenshot job for site without screenshot yet' do
      expect(described_class).to receive(:_seven_days_ago) { Time.utc(2013,4,4) }
      expect(Site).to receive(:find_each).with(select: %w[token], with_state: 'active', created_after: Time.utc(2013,4,4)).and_yield(site1)
      expect(Screenshoter).to receive(:delay).with(queue: 'scout') { delay_stub }
      expect(delay_stub).to receive(:take).with(site_token1, 'initial')

      described_class.take_initial_screenshots
    end
  end

  describe '.take_activity_screenshots' do
    let(:tokens_to_activity_screenshot) { [site_token1] }

    it 'enqueues a screenshot job for site without screenshot yet' do
      expect(Site).to receive(:find_each).with(select: %w[token], with_state: 'active', with_min_billable_video_views: 10).and_yield(site1)
      expect(Screenshoter).to receive(:delay).with(queue: 'scout') { delay_stub }
      expect(delay_stub).to receive(:take).with(site_token1, 'activity')

      described_class.take_activity_screenshots
    end
  end

end
