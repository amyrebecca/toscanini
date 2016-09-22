
module OldWeatherOCR
  class ProcessOCRResult

    include Sidekiq::Worker

    attr_reader :client

    def initialize()
      @client = ::Toscanini::Services::Nanoweather.new()
    end

    def perform(name, subject_id)
      logger.info "fetching OCR result for #{name}"
      response = client.fetch_ocr name, subject_id, logger

      #TODO: process OCR extracts
      fields = response.body

      outfile = File.open "tmp/results.txt", "wb"
      begin
        fields.each do |field|
          r = client.fetch_ocrval name, field, logger
          ocr = r.body
          ocr.strip!

          r = client.fetch_confidence name, field, logger
          confidence = r.body

          outfile.puts "#{field}\t#{confidence}%\t#{ocr}\n"
        end
      ensure
        outfile.close unless outfile.nil?
      end

    end
  end
end
