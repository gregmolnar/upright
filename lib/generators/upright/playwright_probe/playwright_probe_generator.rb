module Upright
  module Generators
    class PlaywrightProbeGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :with_authenticator, type: :boolean, default: false,
        desc: "Generate an authenticator class for this probe"

      def create_probe_file
        template "probe.rb.tt", File.join("probes", "#{file_name}_probe.rb")
      end

      def create_authenticator_file
        if options[:with_authenticator]
          template "authenticator.rb.tt", File.join("probes/authenticators", "#{file_name}.rb")
        end
      end

      private

      def probe_class_name
        "#{class_name}Probe"
      end

      def authenticator_name
        file_name.underscore.to_sym
      end
    end
  end
end
