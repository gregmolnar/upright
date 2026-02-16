module Upright::Playwright::FormAuthentication
  extend ActiveSupport::Concern

  included do
    class_attribute :authentication_service
  end

  class_methods do
    def authenticate_with_form(service)
      self.authentication_service = service
    end
  end

  private
    def authenticated_context(browser, context_options = {})
      if authentication_service
        authenticator_for(authentication_service).new(browser, context_options).authenticated_context
      end
    end

    def authenticator_for(service)
      "::Playwright::Authenticator::#{service.to_s.camelize}".constantize
    end
end
