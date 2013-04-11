class ScreenshotedSite
  include Mongoid::Document
  include Mongoid::Timestamps
  include ApplicationHelper

  cattr_accessor :sites_infos

  MAX_ATTEMPTS = 5
  DELAY = proc { |count| count ** 2 }

  field :t,   type: String
  field :lfa, type: DateTime # last failed at => used for not retrying to take a screenshot everytime
  field :fac, type: Integer, default: 0 # failed attempts count

  embeds_many :screenshots, cascade_callbacks: true, store_as: 's' do
    def latest
      desc(:created_at).first
    end
  end

  index({ t: 1 }, { unique: true })

  validates :t, presence: true, uniqueness: true

  scope :cannot_be_retried, ->(attempts) {
    where(fac: attempts).where(:lfa.gte => ScreenshotedSite::DELAY.call(attempts).days.ago)
  }
  scope :with_max_attempts, -> { where(:fac.gte => ScreenshotedSite::MAX_ATTEMPTS) }

  class << self
    # Returns the screenshoted sites corresponding to the given Site array
    #
    # @param [Array<Site>] sites array of Site instances
    def from_sites(sites)
      @@sites_infos = sites.inject({}) { |hash, s| hash[s.token] = s; hash }

      where(:t.in => sites.map(&:token))
    end

    # Returns the screenshoted sites corresponding to the given Site array
    # sorted by last_30_days_billable_video_views DESC
    #
    # @param [Array<Site>] sites array of Site instances
    def from_sites_sorted_by_billable_views(sites)
      from_sites(sites).sort { |a, b| b.site_info.last_30_days_billable_video_views <=> a.site_info.last_30_days_billable_video_views }
    end
  end

  def site_info
    @site_info ||= self.class.sites_infos[t]
  end

  # This method tells if the latest screenshot of a site is older than the
  # given days count.
  #
  # @param [Datetime] date the date to compare the latest screenshot to.
  #
  # @return [Boolean]
  def latest_screenshot_older_than(days_count)
    screenshots.latest.created_at < days_count.days.ago
  end

  def prepare_for_carousel
    if screenshot = screenshots.latest
      {
        token: t,
        thumb: screenshot ? screenshot.f.url(:carousel) : '/no-screenshot.png',
        link: screenshot ? screenshot.u : url_with_protocol(site_info.hostname),
        hostname: site_info.hostname,
        views: site_info.last_30_days_billable_video_views,
        video_tags: site_info.last_30_days_video_tags,
        tags: site_info.tags.join(', ')
      }
    end
  end
end
