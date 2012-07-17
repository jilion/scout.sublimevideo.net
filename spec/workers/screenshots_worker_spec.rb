require 'fast_spec_helper'
require 'sidekiq'
require 'sidekiq/testing'

require File.expand_path('app/workers/screenshots_worker')

describe ScreenshotsWorker do
  stub_class 'Site', 'ScreenshotedSite', 'ScreenshotWorker'
  
  let(:worker)     { described_class.new }
  let(:site_token) { 'site_token' }

  describe '#perform' do
    it 'calls #take_initial_screenshots, #take_activity_screenshots and #delay_itself' do
      worker.should_receive(:take_initial_screenshots)
      worker.should_receive(:take_activity_screenshots)

      worker.perform
    end
  end

  describe '#take_initial_screenshots' do
    it 'enqueues a screenshot job for site without screenshot yet' do
      ScreenshotWorker.should_receive(:perform_async).with(site_token)

      worker.stub(:tokens_to_initially_screenshot) { |&block| block.call(site_token) }
      worker.take_initial_screenshots
    end
  end

  describe '#take_activity_screenshots' do
    let(:tokens_to_activity_screenshot) { [site_token] }

    it 'enqueues a screenshot job for site without screenshot yet' do
      ScreenshotWorker.should_receive(:perform_async).with(site_token)

      worker.stub(:tokens_to_activity_screenshot) { |&block| block.call(site_token) }
      worker.take_activity_screenshots
    end
  end

  # ===================
  # = Private methods =
  # ===================
  describe '#tokens_to_initially_screenshot' do
    let(:screenshoted_sites1) { [stub(t: 'abc')] }
    let(:screenshoted_sites2) { [stub(t: 'cba')] }
    let(:screenshoted_sites3) { [stub(t: 'def')] }
    let(:active_sites)       { [[stub(token: site_token), stub(token: 'abc'), stub(token: 'cba'), stub(token: 'def'), stub(token: '123')]] }
    before do
      ScreenshotedSite::MAX_ATTEMPTS = 5 unless defined? ScreenshotedSite::MAX_ATTEMPTS
      ScreenshotedSite.should_receive(:where)                              { screenshoted_sites1 }
      ScreenshotedSite.should_receive(:cannot_be_retried).exactly(4).times { screenshoted_sites2 }
      ScreenshotedSite.should_receive(:with_max_attempts)                  { screenshoted_sites3 }
      Site.stub_chain(:active, :with_hostname)                             { active_sites }
    end

    it 'yields 2 tokens' do
      sum = 0
      worker.send(:tokens_to_initially_screenshot, :each) do |token|
        token.should_not eq 'abc'
        sum += 1
      end
      sum.should eq 2
    end
  end

  describe '#tokens_to_activity_screenshot' do
    let(:screenshoted_site_non_eligible) { stub(t: '123abc', latest_screenshot_older_than: false) }
    let(:screenshoted_site_eligible1)    { stub(t: 'abc123', latest_screenshot_older_than: true) }
    let(:screenshoted_site_eligible2)    { stub(t: 'abc456', latest_screenshot_older_than: true) }
    let(:screenshoted_sites) do
      [
        screenshoted_site_non_eligible,
        screenshoted_site_eligible1,
        screenshoted_site_eligible2
      ]
    end
    let(:sites_with_activity) do
      [[
        stub(token: screenshoted_site_non_eligible.t),
        stub(token: screenshoted_site_eligible1.t),
        stub(token: screenshoted_site_eligible2.t)
      ]]
    end
    before do
      ScreenshotedSite.should_receive(:where).with(t: screenshoted_sites.map(&:t)) { screenshoted_sites }
      Site.stub_chain(:active, :with_hostname, :with_min_billable_video_views)     { sites_with_activity }
    end

    it 'yields 2 tokens' do
      sum = 0
      worker.send(:tokens_to_activity_screenshot, :each, { plays_threshold: 10, days_interval: 5 }) do |token|
        token.should_not eq screenshoted_site_non_eligible.t
        sum += 1
      end
      sum.should eq 2
    end
  end
end
