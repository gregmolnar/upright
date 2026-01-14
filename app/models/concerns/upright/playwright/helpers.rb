module Upright
  module Playwright
    module Helpers
      extend ActiveSupport::Concern

      def wait_for_network_idle(target_page = nil)
        (target_page || page).wait_for_load_state(state: "networkidle")
      end
    end
  end
end
