Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :duo,
    issuer: "https://example.auth0.com",
    discovery: false,
    scope: %i[ openid email profile ],
    client_options: {
      identifier: "test-client-id",
      secret: "test-client-secret",
      redirect_uri: "http://app.upright.localhost:3040/auth/duo/callback",
      authorization_endpoint: "https://example.auth0.com/authorize",
      token_endpoint: "https://example.auth0.com/oauth/token",
      userinfo_endpoint: "https://example.auth0.com/userinfo"
    }
end
