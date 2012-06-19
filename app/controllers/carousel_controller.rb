class CarouselController < ApplicationController
  before_filter :set_day

  def new_sites_day
    @sites              = Site.created_on(@day.all_day)
    @screenshoted_sites = ScreenshotedSite.from(@sites)
  end

  def new_active_sites_week
    @sites              = Site.first_billable_plays_on(@day.all_week)
    @screenshoted_sites = ScreenshotedSite.from(@sites)
  end

  private

  def set_day
    @day = params[:day] ? Time.parse(params[:day]) : Time.utc(2010, 9, 15)
  end

end
