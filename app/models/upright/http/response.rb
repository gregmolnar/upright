module Upright
  module HTTP
    class Response
      def initialize(typhoeus_response, log)
        @typhoeus_response = typhoeus_response
        @log = log
      end

      def status
        typhoeus_response.code
      end

      def body
        typhoeus_response.body
      end

      def status_in?(range)
        status.in?(range)
      end

      def network_error?
        timed_out? || connection_failed? || ssl_error?
      end

      def content_type
        typhoeus_response.headers&.[]("content-type") || "application/octet-stream"
      end

      def file_extension
        case content_type
        when /json/ then "json"
        when /html/ then "html"
        when /xml/  then "xml"
        when /text/ then "txt"
        else "bin"
        end
      end

      def verbose_log_content
        @log.tap(&:rewind).read
      end

      private
        attr_reader :typhoeus_response

        def timed_out?
          typhoeus_response.timed_out?
        end

        def connection_failed?
          typhoeus_response.return_code == :couldnt_connect
        end

        def ssl_error?
          typhoeus_response.return_code.to_s.start_with?("ssl")
        end
    end
  end
end
