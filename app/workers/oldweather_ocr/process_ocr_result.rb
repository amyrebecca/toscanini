module Toscanini
  module Workers
    module OldWeatherOCR
      class ProcessOCRResult < ConfigurableWorker
        attr_reader :client

        def initialize()
          @client = ::Toscanini::Services::Nanoweather.new()
        end

        def perform(name, subject_id)
          result = client.fetch_ocr name, subject_id
          logger.info "it worked"
          #TODO: process OCR extracts
        end
      end
    end
  end
end
