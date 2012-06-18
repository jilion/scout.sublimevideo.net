require 'carrierwave/test/matchers'

RSpec.configure do |config|
  config.include CarrierWave::Test::Matchers

  config.before :each, fog_mock: true do
    CarrierWave.fog_configuration
    Fog.mock!
    Fog.credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['S3_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
      region:                'us-east-1'
    }

    unless $fog_connection
      $fog_connection = Fog::Storage.new(:provider => 'AWS')
      $fog_connection.directories.create(key: ENV['S3_SCREENSHOTS_BUCKET'])
    end
  end

  config.after :each, fog_mock: true do
    CarrierWave.file_configuration
  end
end
