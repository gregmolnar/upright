class Upright::Probes::TracerouteProbe < FrozenRecord::Base
  include Upright::Probeable
  include Upright::Traceroute::OtelTracing

  stagger_by_site 3.seconds

  # Probes are loaded from config/upright/probes/traceroute_probes.yml

  TIMEOUT = 60.seconds
  MAX_HOPS = Upright::Traceroute::Result::MAX_HOPS
  PROBE_COUNT = Upright::Traceroute::Result::PROBE_COUNT

  def check
    Upright::Traceroute::Result.for(host).tap do |result|
      @traceroute_result = result
      trace_result(result)
    end.reached_destination?
  end

  def on_check_recorded(probe_result)
    attach_traceroute_json(probe_result, @traceroute_result)
  end

  def probe_type = "traceroute"
  def probe_target = host

  private
    def attach_traceroute_json(probe_result, traceroute_result)
      if traceroute_result.raw_json.present?
        Upright::Artifact.new(name: "traceroute.json", content: traceroute_result.raw_json).attach_to(probe_result)
      end
    end
end
