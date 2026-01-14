module Upright
  module Playwright
    module Authenticator
      class Base
        include Concerns::Playwright::Helpers

        attr_reader :page

        def self.authenticate_on(page)
          new.authenticate_on(page)
        end

        def initialize(browser = nil, context_options = {})
          @browser = browser
          @context_options = context_options
          @storage_state = StorageState.new(service_name)
        end

        def authenticate_on(page)
          @page = page
          authenticate
          self
        end

        def session_valid?
          wait_for_network_idle(page)

          if page.url == signin_redirect_url
            true
          else
            page.goto(signin_redirect_url, timeout: 10.seconds.in_ms)
            !page.url.include?(signin_path)
          end
        end

        def authenticated_context
          if (cached_state = @storage_state.load)
            context = create_context(cached_state)
            return context if context_has_valid_session?(context)
            context.close
          end

          perform_authentication
        end

        protected

        def signin_redirect_url
          raise NotImplementedError
        end

        def signin_path
          raise NotImplementedError
        end

        private

        def service_name
          raise NotImplementedError
        end

        def authenticate
          raise NotImplementedError
        end

        def context_has_valid_session?(context)
          page = context.new_page
          page.goto(signin_redirect_url, timeout: 10.seconds.in_ms)
          !page.url.include?(signin_path)
        rescue ::Playwright::TimeoutError
          false
        ensure
          page&.close
        end

        def perform_authentication
          context = create_context
          @page = context.new_page
          setup_page_logging(page)

          authenticate

          state = context.storage_state
          @storage_state.save(state)
          context.close

          create_context(state)
        end

        def user_agent
          Upright.configuration.user_agent.presence ||
            Concerns::Playwright::Lifecycle::DEFAULT_USER_AGENT
        end

        def create_context(state = nil)
          options = { userAgent: user_agent, serviceWorkers: "block" }
          options[:storageState] = state if state
          options.merge!(@context_options)
          @browser.new_context(**options)
        end

        def setup_page_logging(page)
          if defined?(RailsStructuredLogging::Recorder)
            RailsStructuredLogging::Recorder.instance.messages.tap do |messages|
              page.on("response", ->(response) {
                next if skip_logging?(response)
                RailsStructuredLogging::Recorder.instance.sharing(messages)
                log_response(response)
              })
            end
          else
            page.on("response", ->(response) {
              next if skip_logging?(response)
              log_response(response)
            })
          end
        end

        def log_response(response)
          headers = response.headers.slice("x-request-id", "x-runtime").compact
          Rails.logger.info "#{response.status} #{response.request.resource_type.upcase} #{response.url} #{headers.to_query}"
        end

        def skip_logging?(response)
          %w[image asset avatar].any? { |pattern| response.url.include?(pattern) }
        end

        def credentials
          Rails.application.credentials
        end
      end
    end
  end
end
