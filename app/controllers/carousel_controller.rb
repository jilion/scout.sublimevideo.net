class CarouselController < ApplicationController
  respond_to :html, :js
  before_filter :set_day
  before_filter :redirect_to_beginning_of_week, only: [:new_active_sites_week]

  def new_sites_day
    @sites  = Site.created_on(@day.all_day)#.page params[:page]
    @images = ScreenshotedSite.from(@sites).map(&:prepare_for_carousel).compact.to_json

    respond_to do |format|
      format.html
      format.js { render 'sites' }
    end
  end

  def new_active_sites_week
    @sites  = Site.first_billable_plays_on(@day.all_week)#.page params[:page]
    @images = ScreenshotedSite.from_and_sorted(@sites).map(&:prepare_for_carousel).compact.to_json

    respond_to do |format|
      format.html
      format.js { render 'sites' }
    end
  end

  private

  def set_day
    @day = (params[:day] ? Time.parse(params[:day]) : Time.utc(2010, 9, 15)).midnight
  end

  def redirect_to_beginning_of_week
    redirect_to new_active_sites_week_url(l(@day.beginning_of_week, format: :Y_m_d)) unless @day == @day.beginning_of_week
  end

end
