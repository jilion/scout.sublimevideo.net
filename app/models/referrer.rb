class Referrer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token
  field :url
  field :hits,            type: Integer, default: 0
  field :badge_hits,      type: Integer, default: 0
  field :contextual_hits, type: Integer, default: 0

  attr_accessible :token, :url, :hits, :contextual_hits, :badge_hits

  scope :by_hits, lambda { |way='desc'| order_by([:hits, way.to_sym]) }
end
