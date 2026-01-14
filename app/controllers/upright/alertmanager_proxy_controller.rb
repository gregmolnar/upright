module Upright
  class AlertmanagerProxyController < ApplicationController
    skip_forgery_protection

    def proxy
      proxy_to_alertmanager request.fullpath.delete_prefix("/alertmanager")
    end

    private
      def proxy_to_alertmanager(path, method: request.method, body: nil)
        response = Faraday.new(url: alertmanager_url).run_request(method.downcase.to_sym, path, body, { "Content-Type" => request.content_type })

        render body: response.body, status: response.status, content_type: response.headers["content-type"]
      end

      def alertmanager_url
        ENV.fetch("ALERTMANAGER_URL", "http://upright-alertmanager:9093")
      end
  end
end
