require "opentelemetry/sdk"

OpenTelemetry::SDK.configure do |c|
  c.service_name = "upright-test"
end
