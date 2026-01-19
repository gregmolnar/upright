module Upright::ProbeYamlSource
  extend ActiveSupport::Concern

  class_methods do
    def file_path
      filename = name.demodulize.underscore.pluralize
      Upright.configuration.probes_path.join("#{filename}.yml").to_s
    end
  end
end
