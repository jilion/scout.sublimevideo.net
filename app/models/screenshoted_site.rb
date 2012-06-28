class ScreenshotedSite
  include Mongoid::Document
  include Mongoid::Timestamps

  field :t, type: String

  embeds_many :screenshots, cascade_callbacks: true, store_as: 's' do
    def latest
      desc(:created_at).first
    end
  end

  index({ t: 1 }, { unique: true })

  validates :t, presence: true, uniqueness: true

  class << self
    # Returns the screenshoted sites corresponding to the given Site array
    #
    # @param [Array<Site>] sites array of Site instances
    def from_sites(sites)
      @@tokens      = sites.pluck(:token)
      @@sites_infos = nil

      where(:t.in => @@tokens)
    end

    # Returns the screenshoted sites corresponding to the given Site array
    # sorted by last_30_days_billable_video_views DESC
    #
    # @param [Array<Site>] sites array of Site instances
    def from_sites_sorted_by_billable_views(sites)
      from_sites(sites).sort { |a, b| b.site_info.last_30_days_billable_video_views <=> a.site_info.last_30_days_billable_video_views }
    end

    def sites_info(token)
      @@sites_infos ||= Site.where(token: @@tokens).inject({}) { |hash, s| hash[s.token] = s; hash }
      @@sites_infos[token]
    end
  end

  def site_info
    @site_info ||= self.class.sites_info(t)
  end

  # This method tells if the latest screenshot of a site is older than the
  # given days count.
  #
  # @param [Integer] days_count # of days to compare the latest screenshot to.
  #
  # @return [Boolean]
  def latest_screenshot_older_than(days_count)
    screenshots.latest.created_at < days_count.days.ago
  end

  def prepare_for_carousel
    if screenshot = screenshots.latest
      {
        token: t,
        thumb: screenshot.f.url(:carousel),
        link: screenshot.u,
        hostname: site_info.hostname,
        views: site_info.last_30_days_billable_video_views,
        video_tags: site_info.last_30_days_video_tags
      }
    end
  end
end
