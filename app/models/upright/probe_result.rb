module Upright
  class ProbeResult < ApplicationRecord
    self.table_name = "upright_probe_results"

    scope :by_type, ->(type) { where(probe_type: type) if type.present? }
    scope :by_status, ->(status) { where(status: status) if status.present? }
    scope :by_name, ->(name) { where(probe_name: name) if name.present? }
    scope :stale, -> { where(created_at: ...24.hours.ago) }

    enum :status, [ :ok, :fail, :error ]

    has_many_attached :artifacts

    after_create :increment_metrics

    def to_chart
      {
        created_at: created_at.iso8601,
        duration: duration.to_f,
        status: status,
        probe_name: probe_name
      }
    end

    private
      def increment_metrics
        labels = { type: probe_type, name: probe_name, probe_target: probe_target, probe_service: probe_service }

        if defined?(Yabeda) && Yabeda.respond_to?(:upright_probe_duration_seconds)
          Yabeda.upright_probe_duration_seconds.set(labels.merge(status: status), duration.to_f)
          Yabeda.upright_probe_up.set(labels, ok? ? 1 : 0)
        end
      end
  end
end
