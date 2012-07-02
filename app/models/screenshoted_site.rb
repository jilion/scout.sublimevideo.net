class ScreenshotedSite
  include Mongoid::Document
  include Mongoid::Timestamps

  field :t,   type: String
  field :lfa, type: DateTime # last failed at => used for not retrying to take a screenshot everytime

  embeds_many :screenshots, cascade_callbacks: true, store_as: 's' do
    def latest
      desc(:created_at).first
    end
  end

  index({ t: 1 }, { unique: true })

  validates :t, presence: true, uniqueness: true

  scope :not_failed_or_failed_after, ->(date) { any_of([{ lfa: nil }, { :lfa.gte => date.to_i }]) }

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
      @@sites_infos ||= Site.includes(:tags).where(token: @@tokens).inject({}) { |hash, s| hash[s.token] = s; hash }
      @@sites_infos[token]
    end
  end

  def site_info
    @site_info ||= self.class.sites_info(t)
  end

  # This method tells if the latest screenshot of a site is older than the
  # given days count.
  #
  # @param [Datetime] date the date to compare the latest screenshot to.
  #
  # @return [Boolean]
  def latest_screenshot_older_than(date)
    screenshots.latest.created_at < date
  end

  def prepare_for_carousel
    if screenshot = screenshots.latest
      {
        token: t,
        thumb: screenshot.f.url(:carousel),
        link: screenshot.u,
        hostname: site_info.hostname,
        views: site_info.last_30_days_billable_video_views,
        video_tags: site_info.last_30_days_video_tags,
        tags: site_info.tag_list.join(', ')
      }
    end
  end
end
