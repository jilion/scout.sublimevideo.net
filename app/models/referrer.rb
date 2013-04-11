require 'sublime_video_private_api/model'

class Referrer
  include SublimeVideoPrivateApi::Model
  uses_private_api :my

  def self.by_hits_for(token)
    all(with_tokens: [token], by_hits: 'desc')
  end

end
