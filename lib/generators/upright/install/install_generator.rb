module Upright
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install Upright engine into your application"

      def copy_initializers
        template "upright.rb", "config/initializers/upright.rb"
        template "omniauth.rb", "config/initializers/omniauth.rb"
      end

      def copy_sites_config
        template "sites.yml", "config/sites.yml"
      end

      def create_probe_directories
        empty_directory "probes"
        empty_directory "probes/authenticators"
        template "http_probes.yml", "probes/http_probes.yml"
        template "smtp_probes.yml", "probes/smtp_probes.yml"
        template "traceroute_probes.yml", "probes/traceroute_probes.yml"
      end

      def copy_observability_configs
        template "prometheus.yml", "config/prometheus/prometheus.yml"
        template "upright.rules.yml", "config/prometheus/rules/upright.rules.yml"
        template "alertmanager.yml", "config/alertmanager/alertmanager.yml"
        template "otel_collector.yml", "config/otel_collector.yml"
        template "development_prometheus.yml", "config/prometheus/development/prometheus.yml"
        template "development_alertmanager.yml", "config/alertmanager/development/alertmanager.yml"
      end

      def copy_dev_services
        template "docker-compose.yml", "docker-compose.yml"
      end

      def copy_deploy_config
        template "deploy.yml", "config/deploy.yml"
      end

      def copy_puma_config
        template "puma.rb", "config/puma.rb"
      end

      def add_routes
        route 'mount Upright::Engine => "/", as: :upright'
      end

      def install_active_storage
        rails_command "active_storage:install"
      end

      def configure_javascript
        append_to_file "app/javascript/application.js", 'import "upright/application"'
      end

      def show_post_install_message
        say ""
        say "Upright has been installed!", :green
        say ""
        say "Next steps:"
        say "  1. Run migrations: bin/rails db:migrate"
        say "  2. Configure your servers in config/deploy.yml"
        say "  3. Configure sites in config/sites.yml"
        say "  4. Add probes in probes/*.yml"
        say "  5. Set ADMIN_PASSWORD env var (default: upright)"
        say ""
        say "For production, review config/initializers/upright.rb and update:"
        say "  config.hostname = \"honcho-upright.com\""
        say ""
        say "Start dev services (Prometheus, Alertmanager, Playwright):"
        say "  docker compose up -d"
        say ""
        say "Start the development server with: bin/dev"
        say ""
        say "Then access your app at:"
        say "  http://app.#{app_name}.localhost:3000"
        say ""
      end

      private
        def app_name
          Rails.application.class.module_parent_name.underscore.dasherize
        end

        def app_domain
          "#{app_name}.example.com"
        end
    end
  end
end
