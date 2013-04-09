class Site
  include SublimeVideoPrivateApi::Model
  uses_private_api :my

  SKIPPED_DOMAINS = %w[please-edit.me test.com facebook.com youtube.com youtu.be vimeo.com dailymotion.com google.com dropbox.com dl.dropbox.com]

  def self.all_new_sites_for(timestamp)
    all(default_params.merge(created_on: timestamp, by_date: 'desc', select: %w[id token hostname last_30_days_main_video_views last_30_days_extra_video_views last_30_days_embed_video_views last_30_days_video_tags]))
  end

  def self.all_new_active_sites_for(timestamp)
    all(default_params.merge(first_billable_plays_on_week: timestamp, by_last_30_days_billable_video_views: 'desc'))
  end

  def self.default_params
    { includes: 'tags', with_state: 'active', without_hostnames: SKIPPED_DOMAINS, not_tagged_with: 'adult' }
  end

  def last_30_days_billable_video_views
    @last_30_days_billable_video_views ||= last_30_days_main_video_views.to_i + last_30_days_extra_video_views.to_i + last_30_days_embed_video_views.to_i
  end

  def safe_status
    tags.include?('safe') ? 'safe' : 'not_safe'
  end

end
