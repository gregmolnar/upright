module Upright::SubdomainScoping
  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_app_subdomain, if: -> { request.subdomain.blank? }
    before_action :set_current_subdomain
  end

  private
    def redirect_to_app_subdomain
      redirect_to root_url(default_url_options.merge(subdomain: Upright.configuration.global_subdomain)), allow_other_host: true
    end

    def set_current_subdomain
      Upright::Current.subdomain = request.subdomain.presence
      Upright::Current.site = Upright.find_site(Upright::Current.subdomain)
    end
end
