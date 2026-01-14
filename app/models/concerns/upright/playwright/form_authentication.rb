module Upright
  module Playwright
    module FormAuthentication
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
            # First try the host app's authenticator, then fall back to engine's
            "::Playwright::Authenticator::#{service.to_s.camelize}".constantize
          rescue NameError
            "Upright::Playwright::Authenticator::#{service.to_s.camelize}".constantize
          end
    end
  end
end
