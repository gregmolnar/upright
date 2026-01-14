module Upright
  module SubdomainScoping
    extend ActiveSupport::Concern

    included do
      before_action :redirect_to_app_subdomain, if: -> { request.subdomain.blank? }
      before_action :set_current_subdomain
    end

    private
      def redirect_to_app_subdomain
        redirect_to host_app_routes.root_url(default_url_options.merge(subdomain: "app")), allow_other_host: true
      end

      def set_current_subdomain
        Upright::Current.subdomain = request.subdomain.presence
        Upright::Current.site = Upright::Node.find_by_subdomain(Upright::Current.subdomain)&.site
      end

      def host_app_routes
        Rails.application.routes.url_helpers
      end
  end
end
