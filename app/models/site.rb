class Site < ActiveRecord::Base

  SKIPPED_DOMAINS = %w[please-edit.me test.com facebook.com youtube.com youtu.be vimeo.com dailymotion.com google.com dropbox.com dl.dropbox.com]

  acts_as_taggable

  scope :active,        lambda { where(state: 'active') }
  scope :without_hostname, ->(hostnames = []) {
    where { (hostname != nil) & (hostname != '') }.
    where { hostname << hostnames }
  }
  scope :with_min_billable_video_views, lambda { |min|
    where("(sites.last_30_days_main_video_views + sites.last_30_days_extra_video_views + sites.last_30_days_embed_video_views) >= #{min}")
  }
  scope :created_on, lambda { |timestamp|
    where(created_at: timestamp.all_day)
  }
  scope :first_billable_plays_on_week, lambda { |timestamp|
    where(first_billable_plays_at: timestamp.all_week)
  }
  scope :by_last_30_days_billable_video_views, lambda { |way = 'desc'|
    order("(sites.last_30_days_main_video_views + sites.last_30_days_extra_video_views + sites.last_30_days_embed_video_views) #{way}")
  }

  def last_30_days_billable_video_views
    @last_30_days_billable_video_views ||= last_30_days_main_video_views.to_i + last_30_days_extra_video_views.to_i + last_30_days_embed_video_views.to_i
  end

end
