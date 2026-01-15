module Upright::Staggerable
  extend ActiveSupport::Concern

  class_methods do
    def stagger_by_site(interval)
      self.stagger_interval = interval
    end

    def stagger_delay
      if stagger_interval
        current_site = Upright.current_site
        stagger_interval * current_site.stagger_index
      else
        0.seconds
      end
    end
  end

  included do
    class_attribute :stagger_interval, default: nil
  end
end
