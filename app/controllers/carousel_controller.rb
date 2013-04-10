class CarouselController < ApplicationController
  respond_to :html

  before_filter :set_day
  before_filter :redirect_to_beginning_of_week, only: [:new_active_sites_week]

  protect_from_forgery except: [:take]

  def new_sites_day
    load_images(Site.all_new_sites_for(@day))
  end

  def new_active_sites_week
    load_images(Site.all_new_active_sites_for(@day))
  end

  def take
    ScreenshotWorker.perform_async(params[:token])
    render text: "Screenshot for #{params[:token]} will be re-taken!"
  end

  private

  def set_day
    @day = (params[:day] ? Time.parse(params[:day]) : Time.now.utc).midnight
  end

  def redirect_to_beginning_of_week
    redirect_to new_active_sites_week_url(l(@day.beginning_of_week, format: :Y_m_d)) unless @day == @day.beginning_of_week
  end

  def load_images(sites)
    @images = ScreenshotedSite.from_sites_sorted_by_billable_views(sites).map(&:prepare_for_carousel).compact.to_json
  end

end
