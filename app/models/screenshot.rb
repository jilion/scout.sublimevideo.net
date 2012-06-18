class Screenshot
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :u, type: String
  field :f, type: String

  embedded_in :site, class_name: 'ScreenshotedSite'

  mount_uploader :f, ScreenshotUploader

  validates :u, :f, presence: true
end
