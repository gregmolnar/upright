module Upright
  class SessionsController < ApplicationController
    skip_before_action :authenticate_user, only: [ :new, :create ]

    before_action :ensure_not_signed_in, only: [ :new, :create ]

    def new
    end

    def create
      user = User.from_omniauth(request.env["omniauth.auth"])
      session[:user_info] = { email: user.email, name: user.name }
      redirect_to main_app.root_path
    end

    def destroy
      reset_session
      redirect_to main_app.root_path(subdomain: "app"), allow_other_host: true
    end

    private
      def ensure_not_signed_in
        redirect_to main_app.host_root_path if session[:user_info].present?
      end
  end
end
