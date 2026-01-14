module Upright
  module Playwright
    class StorageState
      def initialize(service)
        @service = service
      end

      def exists?
        path.exist?
      end

      def load
        JSON.parse(path.read) if exists?
      end

      def save(state)
        FileUtils.mkdir_p(storage_dir)
        path.write(JSON.pretty_generate(state))
      end

      def clear
        path.delete if exists?
      end

      private
        def storage_dir
          Upright.configuration.storage_state_dir
        end

        def path
          storage_dir.join("#{@service}.json")
        end
    end
  end
end
