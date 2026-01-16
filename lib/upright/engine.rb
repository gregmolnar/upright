class Upright::Engine < ::Rails::Engine
  isolate_namespace Upright

  # Add concerns to autoload paths
  config.autoload_paths << root.join("app/models/concerns")

  # Configure Solid Queue as the job backend
  initializer "upright.solid_queue", before: :set_configs_for_current_railties do |app|
    app.config.active_job.queue_adapter = :solid_queue
    app.config.solid_queue.connects_to = { database: { writing: :queue, reading: :queue } }
  end

  # Disable Mission Control HTTP basic auth (engine handles authentication)
  initializer "upright.mission_control" do
    MissionControl::Jobs.http_basic_auth_enabled = false
  end

  # Configure acronym inflections for autoloading
  initializer "upright.inflections", before: :bootstrap_hook do
    ActiveSupport::Inflector.inflections(:en) do |inflect|
      inflect.acronym "HTTP"
      inflect.acronym "SMTP"
    end
  end

  config.generators do |g|
    g.test_framework :minitest
  end

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
  initializer "upright.yabeda" do
    Upright::Metrics.configure
  end

  # Configure OpenTelemetry
  initializer "upright.opentelemetry" do
    Upright::Tracing.configure
  end

  # Allow host app to override views
  config.to_prepare do
    Upright::ApplicationController.helper Rails.application.helpers if defined?(Rails.application)
  end

  # Add engine migrations to host app
  initializer "upright.migrations" do |app|
    unless app.root.to_s == root.join("test/dummy").to_s
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end
  end
end
