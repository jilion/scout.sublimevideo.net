class Site < ActiveRecord::Base

  acts_as_taggable

  paginates_per 20

  scope :active,        where { state == 'active' }
  scope :with_hostname, where { (hostname != nil) & (hostname != '') }
  scope :with_min_billable_video_views, lambda { |min|
    where("(sites.last_30_days_main_video_views + sites.last_30_days_extra_video_views + sites.last_30_days_embed_video_views) >= #{min}")
  }
  scope :created_on, lambda { |day|
    tagged_with('adult', exclude: true).where(created_at: day).order('created_at desc')
  }
  scope :first_billable_plays_on, lambda { |day|
    tagged_with('adult', exclude: true).where(first_billable_plays_at: day).by_last_30_days_billable_video_views
  }
  scope :by_last_30_days_billable_video_views, lambda { |way = 'desc'|
    order("(sites.last_30_days_main_video_views + sites.last_30_days_extra_video_views + sites.last_30_days_embed_video_views) #{way}")
  }

  def last_30_days_billable_video_views
    @last_30_days_billable_video_views ||= last_30_days_main_video_views.to_i + last_30_days_extra_video_views.to_i + last_30_days_embed_video_views.to_i
  end

end
