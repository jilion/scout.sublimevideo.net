class StatsController < ApplicationController
  respond_to :html

  def index
    @active_with_hostname_sites = Site.active.with_hostname
    @valid_screenshited_sites   = ScreenshotedSite.where(lfa: nil)
    @invalid_screenshited_sites = ScreenshotedSite.where(:lfa.ne => nil)
  end

end
