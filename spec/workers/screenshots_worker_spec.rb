require 'fast_spec_helper'
require 'sidekiq'
require 'sidekiq/testing'

require File.expand_path('app/workers/screenshots_worker')

describe ScreenshotsWorker do
  stub_class 'Site', 'ScreenshotedSite', 'ScreenshotWorker'

  let(:worker)      { described_class.new }
  let(:site_token1) { 'site_token1' }
  let(:site_token2) { 'site_token1' }
  let(:site1) { stub(token: site_token1) }
  let(:site2) { stub(token: site_token2) }

  describe '#perform' do
    it 'calls #take_initial_screenshots, #take_activity_screenshots and #delay_itself' do
      worker.should_receive(:take_initial_screenshots)
      worker.should_receive(:take_activity_screenshots)

      worker.perform
    end
  end

  describe '#take_initial_screenshots' do
    it 'enqueues a screenshot job for site without screenshot yet' do
      ScreenshotWorker.should_receive(:perform_async).with(site_token1)
      ScreenshotWorker.should_receive(:perform_async).with(site_token2)

      worker.stub(:_sites_to_initially_screenshot) { [site1, site2] }
      worker.take_initial_screenshots
    end
  end

  describe '#take_activity_screenshots' do
    let(:tokens_to_activity_screenshot) { [site_token1] }

    it 'enqueues a screenshot job for site without screenshot yet' do
      ScreenshotWorker.should_receive(:perform_async).with(site_token1)
      ScreenshotWorker.should_receive(:perform_async).with(site_token2)

      worker.stub(:_sites_to_activity_screenshot) { [site1, site2] }
      worker.take_activity_screenshots
    end
  end

  # ===================
  # = Private methods =
  # ===================
  describe '#_sites_to_initially_screenshot' do
    let(:tokens_to_not_screenshot) { ['abc', 'cba', 'def'] }
    before do
      worker.should_receive(:_tokens_to_not_screenshot) { tokens_to_not_screenshot }
    end

    context 'site has already been screenshoted' do
      before do
        Site.should_receive(:find_each).with(select: %w[token], with_state: 'active').and_yield(stub(token: 'abc'))
      end

      it 'returns an empty array' do
        worker.send(:_sites_to_initially_screenshot).should be_empty
      end
    end

    context 'site has never been screenshoted' do
      before do
        Site.should_receive(:find_each).with(select: %w[token], with_state: 'active').and_yield(site1)
      end

      it 'returns 1 site' do
        worker.send(:_sites_to_initially_screenshot).should eq [site1]
      end
    end
  end

  describe '#_sites_to_activity_screenshot' do
    let(:screenshoted_site1) { stub(t: site_token1, latest_screenshot_older_than: false) }
    let(:screenshoted_site2) { stub(t: site_token2, latest_screenshot_older_than: true) }

    context 'site with last screenshot not older enough' do
      before do
        ScreenshotedSite.should_receive(:find_by_t).with(site_token1) { screenshoted_site1 }
        Site.should_receive(:find_each).with(select: %w[token], with_state: 'active', with_min_billable_video_views: 10).and_yield(site1)
      end

      it 'returns an empty array' do
        worker.send(:_sites_to_activity_screenshot, plays_threshold: 10, days_interval: 5).should be_empty
      end
    end

    context 'site with last screenshot older enough' do
      before do
        ScreenshotedSite.should_receive(:find_by_t).with(site_token2) { screenshoted_site2 }
        Site.should_receive(:find_each).with(select: %w[token], with_state: 'active', with_min_billable_video_views: 10).and_yield(site2)
      end

      it 'returns 1 site' do
        worker.send(:_sites_to_activity_screenshot, plays_threshold: 10, days_interval: 5).should eq [site2]
      end
    end
  end
end
