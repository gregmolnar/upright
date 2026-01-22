# WARNING: Change the default password before deploying to production!
# Set the ADMIN_PASSWORD environment variable or update the credentials below.

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :static_credentials,
    title: "Sign In",
    credentials: { "admin" => ENV.fetch("ADMIN_PASSWORD", "upright") }
end
