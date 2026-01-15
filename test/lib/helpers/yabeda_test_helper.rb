module YabedaTestHelper
  extend ActiveSupport::Concern

  included do
    teardown { Yabeda::TestAdapter.instance.reset! }
  end

  def yabeda_gauge_value(gauge, **tags)
    gauge_values = Yabeda::TestAdapter.instance.gauges.fetch(Yabeda.upright.public_send(gauge))
    _, value = gauge_values.find { |recorded_tags, _| tags <= recorded_tags }
    value
  end
end
