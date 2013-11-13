require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'models/site'

describe Site do
  let(:day)   { Time.utc(2013,4,9) }
  let!(:site) { Site.new(hostname: 'baz.com', created_at: Time.utc(2013,4,9)) }

  before do
    Site.new(hostname: nil)
    Site.new(hostname: '')
    Site.new(hostname: 'facebook.com')
    Site.new(hostname: 'google.com')
    Site.new(hostname: 'foo.com', state: 'archived')
    Site.new(hostname: 'bar.com', created_at: Time.utc(2013,4,8))

    stub_api_for(described_class) do |stub|
      default_params = ['not_tagged_with=adult']
      described_class::SKIPPED_DOMAINS.each { |domain| default_params << "without_hostnames[]=#{domain}" }

      # all_new_sites_for
      params = default_params.dup << "created_on=#{day}" << 'by_date=desc'
      stub.get("/private_api/sites?#{params.sort.join('&')}") { |env| [200, {}, [site].to_json] }

      # all_new_active_sites_for
      params = default_params.dup << "first_admin_starts_on_week=#{day}" << 'by_last_30_days_admin_starts=desc'
      stub.get("/private_api/sites?#{params.sort.join('&')}") { |env| [200, {}, [site].to_json] }

      stub.get("/private_api/sites/1") { |env| [200, {}, site.to_json] }
    end
  end

  describe '.all_new_sites_for' do
    let(:sites) { described_class.all_new_sites_for(Time.utc(2013,4,9)) }

    it 'returns sites with a hostname which is not in SKIPPED_DOMAINS' do
      expect(sites.size).to eq(1)
      expect(sites[0].hostname).to eq site.hostname
    end

    it 'returns only active sites' do
      expect(sites.size).to eq(1)
      expect(sites[0].hostname).to eq site.hostname
    end

    it 'returns only sites created on date' do
      expect(sites.size).to eq(1)
      expect(sites[0].hostname).to eq site.hostname
    end
  end

  describe '.all_new_active_sites_for' do
    let(:sites) { described_class.all_new_active_sites_for(Time.utc(2013,4,9)) }

    it 'returns sites with a hostname which is not in SKIPPED_DOMAINS' do
      expect(sites.size).to eq(1)
      expect(sites[0].hostname).to eq site.hostname
    end

    it 'returns only active sites' do
      expect(sites.size).to eq(1)
      expect(sites[0].hostname).to eq site.hostname
    end

    it 'returns only sites created on date' do
      expect(sites.size).to eq(1)
      expect(sites[0].hostname).to eq site.hostname
    end
  end
end
