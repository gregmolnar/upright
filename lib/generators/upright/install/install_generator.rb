module Upright
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install Upright engine into your application"

      def copy_initializer
        template "upright.rb", "config/initializers/upright.rb"
      end

      def copy_sites_config
        template "sites.yml", "config/sites.yml"
      end

      def create_probe_directories
        empty_directory "config/probes"
        template "http_probes.yml", "config/probes/http_probes.yml"
        template "smtp_probes.yml", "config/probes/smtp_probes.yml"
      end

      def copy_observability_configs
        template "prometheus.yml", "config/prometheus/prometheus.yml"
        template "alertmanager.yml", "config/alertmanager/alertmanager.yml"
        template "otel_collector.yml", "config/otel_collector.yml"
      end

      def add_routes
        route 'mount Upright::Engine => "/monitoring"'
      end

      def show_post_install_message
        say ""
        say "Upright has been installed!", :green
        say ""
        say "Next steps:"
        say "  1. Run migrations: bin/rails db:migrate"
        say "  2. Configure sites in config/sites.yml"
        say "  3. Add probes in config/probes/*.yml"
        say "  4. Configure authentication in config/initializers/upright.rb"
        say ""
      end
    end
  end
end
