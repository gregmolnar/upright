module Upright::ExceptionRecording
  extend ActiveSupport::Concern

  EXCEPTION_FILENAME = "exception.txt"

  included do
    attr_accessor :error

    after_create :attach_exception
  end

  def attach_exception
    if error
      artifacts.attach(
        io: StringIO.new(format_exception(error)),
        filename: EXCEPTION_FILENAME,
        content_type: "text/plain"
      )
    end
  end

  def exception_artifact
    artifacts.find { |a| a.filename.to_s == EXCEPTION_FILENAME }
  end

  def exception_report
    exception_artifact&.download
  end

  private
    def format_exception(exception)
      lines = [ "#{exception.class}: #{exception.message}" ]
      if exception.backtrace
        lines.concat(exception.backtrace.first(20).map { |line| "  #{line}" })
      end
      lines.join("\n")
    end
end
