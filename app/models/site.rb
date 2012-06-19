class Site < ActiveRecord::Base

  acts_as_taggable

  scope :active,        where { state == 'active' }
  scope :with_hostname, where { (hostname != nil) & (hostname != '') }
  scope :with_min_billable_video_views, lambda { |min|
    where("(sites.last_30_days_main_video_views + sites.last_30_days_extra_video_views + sites.last_30_days_embed_video_views) >= #{min}")
  }
  scope :created_on,              lambda { |day| tagged_with('adult', exclude: true).where(created_at: day) }
  scope :first_billable_plays_on, lambda { |day| tagged_with('adult', exclude: true).where(first_billable_plays_at: day) }
end
