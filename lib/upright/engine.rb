module Upright
  class Engine < ::Rails::Engine
    isolate_namespace Upright

    # Add concerns to autoload paths
    config.autoload_paths << root.join("app/models/concerns")

    config.generators do |g|
      g.test_framework :minitest
    end

    # Add engine's JavaScript to asset paths
    initializer "upright.assets" do |app|
      app.config.assets.paths << root.join("app/javascript")
    end

    # Configure importmap pins for the engine
    initializer "upright.importmap", before: "importmap" do |app|
      if defined?(Importmap::Engine)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    # Configure FrozenRecord base path
    initializer "upright.frozen_record" do
      if defined?(FrozenRecord)
        FrozenRecord::Base.base_path = Upright.configuration.frozen_record_path
      end
    end

    # Configure Yabeda metrics
    initializer "upright.yabeda", after: "yabeda.configure" do
      Upright::Metrics.configure if defined?(Yabeda)
    end

    # Configure OpenTelemetry
    initializer "upright.opentelemetry" do
      if defined?(OpenTelemetry)
        Upright::Tracing.configure
      end
    end

    # Allow host app to override views
    config.to_prepare do
      Upright::ApplicationController.helper Rails.application.helpers if defined?(Rails.application)
    end

    # Add engine migrations to host app
    initializer "upright.migrations" do |app|
      unless app.root.to_s.match?(root.to_s)
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
