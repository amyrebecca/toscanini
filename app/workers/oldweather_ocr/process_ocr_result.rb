module Toscanini
  module Workers
    module OldWeatherOCR
      class ProcessOCRResult < ConfigurableWorker
        attr_reader :client

        def initialize()
          @client = ::Toscanini::Services::Nanoweather.new()
        end

        def perform(subject_id)
          result = client.fetch_ocr subject_id
          #TODO: process OCR extracts
        end
      end
    end
  end
end
