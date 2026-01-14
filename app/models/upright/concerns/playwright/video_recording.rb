module Upright
  module Concerns
    module Playwright
      module VideoRecording
        extend ActiveSupport::Concern

        VIDEO_SIZE = { width: 1280, height: 720 }

        included do
          attr_accessor :video_path, :video_object

          set_callback :page_ready, :after, :capture_video_reference
          set_callback :page_close, :after, :finalize_video
        end

        private
          def video_dir
            Upright.configuration.video_storage_dir
          end

          def finalize_video
            save_video
          end

          def video_recording_options
            if record_video?
              FileUtils.mkdir_p(video_dir)
              { record_video_dir: video_dir.to_s, record_video_size: VIDEO_SIZE }
            else
              {}
            end
          end

          def record_video?
            !Rails.env.test?
          end

          def capture_video_reference
            self.video_object = page.video if record_video?
          end

          def save_video
            if video_object
              self.video_path = video_dir.join("#{SecureRandom.hex}.webm").to_s
              video_object.save_as(video_path)
            end
          end

          def attach_video(probe_result)
            if video_path
              File.open(video_path, "rb") do |file|
                Artifact.new(name: "#{probe_name}.webm", content: file).attach_to(probe_result, timestamped: true)
              end

              if logger.respond_to?(:struct) && probe_result.artifacts.any?
                logger.struct probe_artifact_url: Rails.application.routes.url_helpers.rails_blob_url(probe_result.artifacts.first, expires_in: 24.hours)
              end

              FileUtils.rm(video_path)
              self.video_path = nil
            end
          end
      end
    end
  end
end
