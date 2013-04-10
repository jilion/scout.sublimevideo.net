# encoding: utf-8
require 'carrierwave/processing/mini_magick'

class ScreenshotUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::MiniMagick

  process :set_content_type
  version :carousel do
    process resize_to_fill: [1100, 825, 'North']
  end
  after :remove, :delete_empty_upstream_dirs

  def fog_directory
    ENV['S3_SCREENSHOTS_BUCKET']
  end

  def url(*args)
    super.to_s.gsub(/#{fog_directory}.s3.amazonaws.com/, "s3.amazonaws.com/#{fog_directory}")
  end

  def fog_public
    false
  end

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "screenshots/#{model.site.t}"
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    pretty_filename = model.u.gsub(%r{http://}, '').parameterize
    "#{model.id}-#{pretty_filename}.#{file.extension}" if original_filename
  end

  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) # fails if path not empty dir
  rescue SystemCallError
    true # nothing, the dir is not empty
  end

end
