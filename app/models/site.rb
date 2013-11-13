require 'sublime_video_private_api/model'

class Site
  include SublimeVideoPrivateApi::Model
  uses_private_api :my

  SKIPPED_DOMAINS = %w[please-edit.me test.com facebook.com youtube.com youtu.be vimeo.com dailymotion.com google.com dropbox.com dl.dropbox.com]

  def self.all_new_sites_for(timestamp)
    all(_default_params.merge(created_on: timestamp, by_date: 'desc', per: 1000))
  end

  def self.all_new_active_sites_for(timestamp)
    all(_default_params.merge(first_admin_starts_on_week: timestamp, by_last_30_days_admin_starts: 'desc', per: 1000))
  end

  def safe_status
    tags.include?('safe') ? 'safe' : 'not_safe'
  end

  def add_tag(tag)
    self.class.put(:add_tag, id: token, tag: tag)
  end

  private

  def self._default_params
    {
      select: %w[last_30_days_admin_starts last_30_days_video_tags],
      without_hostnames: SKIPPED_DOMAINS, not_tagged_with: 'adult'
    }
  end

end
