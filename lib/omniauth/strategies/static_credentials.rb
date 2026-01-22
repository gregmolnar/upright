require "omniauth"

module OmniAuth
  module Strategies
    class StaticCredentials
      include OmniAuth::Strategy

      option :name, "static_credentials"
      option :title, "Sign In"
      option :credentials, {}

      def request_phase
        OmniAuth::Form.build(title: options.title, url: callback_path) do
          text_field "Username", "username"
          password_field "Password", "password"
        end.to_response
      end

      def callback_phase
        if valid_credentials?
          super
        else
          fail!(:invalid_credentials)
        end
      end

      uid { username }

      info do
        { name: username, email: "#{username}@localhost" }
      end

      protected

        def valid_credentials?
          return false if username.blank? || password.blank?

          configured_credentials.any? do |user, pass|
            ActiveSupport::SecurityUtils.secure_compare(username, user.to_s) &&
              ActiveSupport::SecurityUtils.secure_compare(password, pass.to_s)
          end
        end

        def configured_credentials
          options.credentials || {}
        end

        def username
          request.params["username"]
        end

        def password
          request.params["password"]
        end
    end
  end
end
