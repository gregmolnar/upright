Upright.configure do |config|
  config.probes_path = Rails.root.join("config/upright/probes")
  config.frozen_record_path = Rails.root.join("config")
  config.user_agent = "Upright-Test/1.0"
end
