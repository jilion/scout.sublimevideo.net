require 'sublime_video_private_api/model'

class SiteStatAdmin
  include SublimeVideoPrivateApi::Model
  uses_private_api :stats
  collection_path '/private_api/sites/:site_token/site_admin_stats'

  def self.by_hits_for(token)
    get_raw(:last_pages, _site_token: token)[:parsed_data][:data][:pages]
  end
end
