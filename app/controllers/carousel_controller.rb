class CarouselController < ApplicationController
  before_filter :set_day

  def new_sites_day
    @sites = Site.tagged_with('adult', exclude: true).where(created_at: @day.all_day)
    @screenshoted_sites = ScreenshotedSite.where(:t.in => @sites.pluck(:token))
  end

  def new_active_sites_week
    @sites = Site.tagged_with('adult', exclude: true).where(first_billable_plays_at: @day.all_week)
    @screenshoted_sites = ScreenshotedSite.where(:t.in => @sites.pluck(:token))
  end

  private

  def set_day
    @day = params[:day] ? Time.parse(params[:day]) : Time.utc(2010, 9, 15)
  end

end
