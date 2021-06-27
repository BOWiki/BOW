# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.development?
    config.storage = :file
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    config.storage = :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_KEY_ID']
    }
    config.fog_directory = ENV['S3_BUCKET']
  end
end
