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

  # This method tells if the latest screenshot of a site is older than the
  # given days count.
  #
  # @param [Integer] days_count # of days to compare the latest screenshot to.
  #
  # @return [Boolean]
  def latest_screenshot_older_than(days_count)
    screenshots.latest.created_at < days_count.days.ago
  end

  # Returns the screenshoted sites corresponding to the given Site array
  #
  # @param [Array<Site>] sites array of Site instances
  def self.from(sites)
    where(:t.in => sites.pluck(:token))
  end

  def site
    @site ||= Site.find_by_token(t)
  end
end
