Upright.configure do |config|
  config.hostname = "upright.localhost"
  config.user_agent = "Upright-Test/1.0"
  config.auth_provider = :openid_connect
end
