module AuthenticationHelper
  def sign_in(email: "test@example.com", name: "Test User")
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:duo] = OmniAuth::AuthHash.new({
      provider: "duo",
      info: { email: email, name: name }
    })

    on_subdomain :app
    get upright.auth_callback_url(:duo)
  end

  def sign_out
    delete upright.session_path
  end
end
