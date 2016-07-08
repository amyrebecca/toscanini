module Toscanini
  module Workers
    module OldWeatherOCR
      class RequestOCR < ConfigurableWorker

        attr_reader :client

        def initialize()
          @client = ::Toscanini::Services::Nanoweather.new()
        end

        def perform(name="no filename", how_long=1)

          sleep how_long
          begin
            client.request_ocr
            PollOCR.perform_async name
          rescue NotImplementedError => ex
            logger.warn "Failed to request OCR of subject #{name}: #{ex.to_s}"
          rescue Exception => ex
            # TODO: rescue more specific errors
            logger.warn "Failed to request OCR of subject #{name}: #{ex.to_s}"
            raise
          end

          logger.info "OCR-ing subject #{name} for #{how_long} seconds"
        end

      end
    end
  end
end
