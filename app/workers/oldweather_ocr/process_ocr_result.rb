module Toscanini
  module Workers
    module OldWeatherOCR
      class ProcessOCRResult

        include Sidekiq::Worker

        attr_reader :client

        def initialize()
          @client = ::Toscanini::Services::Nanoweather.new()
        end

        def perform(name, subject_id)
          logger.info "fetching OCR result for #{name}"
          result = client.fetch_ocr name, subject_id, logger
          #TODO: process OCR extracts
        end
      end
    end
  end
end
