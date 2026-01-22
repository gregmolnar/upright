module AuthenticationHelper
  def sign_in(email: "test@example.com", name: "Test User")
    provider = Upright.configuration.auth_provider

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new({
      provider: provider.to_s,
      uid: email,
      info: { email: email, name: name }
    })

    on_subdomain :app
    get upright.auth_callback_url(provider)
  end

  def sign_out
    delete upright.session_path
  end
end
