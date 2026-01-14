module Upright
  class ApplicationController < ActionController::Base
    include SubdomainScoping
    include Authentication

    protect_from_forgery with: :exception

    private
      def default_url_options
        Rails.application.routes.default_url_options
      end
  end
end
