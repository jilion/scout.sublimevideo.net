require 'sublime_video_private_api/model'

class Site
  include SublimeVideoPrivateApi::Model
  uses_private_api :my

  SKIPPED_DOMAINS = %w[please-edit.me test.com facebook.com youtube.com youtu.be vimeo.com dailymotion.com google.com dropbox.com dl.dropbox.com]

  def self.all_new_sites_for(timestamp)
    all(default_params.merge(created_on: timestamp, by_date: 'desc', per: 1000))
  end

  def self.all_new_active_sites_for(timestamp)
    all(default_params.merge(first_billable_plays_on_week: timestamp, by_last_30_days_billable_video_views: 'desc', per: 1000))
  end

  def self.default_params
    {
      select: %w[id token hostname last_30_days_main_video_views last_30_days_extra_video_views last_30_days_embed_video_views last_30_days_video_tags],
      without_hostnames: SKIPPED_DOMAINS, not_tagged_with: 'adult'
    }
  end

  def last_30_days_billable_video_views
    @last_30_days_billable_video_views ||= begin
      last_30_days_main_video_views.to_i + last_30_days_extra_video_views.to_i + last_30_days_embed_video_views.to_i
    end
  end

  def safe_status
    tags.include?('safe') ? 'safe' : 'not_safe'
  end

  def add_tag(tag)
    self.class.put(:add_tag, id: token, tag: tag)
  end

end
