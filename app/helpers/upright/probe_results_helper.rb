module Upright::ProbeResultsHelper
  PROBE_TYPE_ICONS = {
    http: "🌐",
    playwright: "🎭",
    ping: "📶",
    smtp: "✉️",
    traceroute: "🛤️"
  }

  def probe_type_icon(probe_type)
    icon = PROBE_TYPE_ICONS.fetch(probe_type.to_s.downcase.to_sym)
    content_tag(:span, icon, title: probe_type.titleize)
  end

  def type_filter_link(label, probe_type = nil)
    current = params[:probe_type].presence
    display_label = probe_type ? safe_join([ probe_type_icon(probe_type), " ", label ]) : label

    link_to display_label,
            site_root_path(probe_type: probe_type.presence, status: params[:status].presence, probe_name: params[:probe_name].presence),
            class: class_names(active: current == probe_type)
  end

  def artifact_icon(artifact)
    case artifact.filename
    when ExceptionRecording::EXCEPTION_FILENAME then "💥"
    when /\.webm$/        then "🎬"
    when /^request\.log$/ then "📤"
    when /^response\./    then "📥"
    when /^smtp\.log$/    then "📧"
    else "📎"
    end
  end

  def results_summary(page)
    total = page.recordset.records_count
    current_count = page.records.size

    parts = if page.recordset.page_count > 1
      [ "Showing #{current_count} of #{total} results" ]
    else
      [ "Showing #{total} results" ]
    end

    parts << "for #{params[:probe_type]} probes" if params[:probe_type].present?
    parts << "named #{params[:probe_name]}" if params[:probe_name].present?
    parts << "with status #{params[:status]}" if params[:status].present?
    parts.join(" ")
  end
end
