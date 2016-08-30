require 'faraday'

module Toscanini
  module Services
    class Nanoweather
      include Configurable

      self.config_file = "nanoweather"
      self.api_prefix = "nanoweather"

      NANO_API_PATH = "/NanoWeather/rest/NanoWeather"
      NANO_DELIMITER = "~"
      MAX_FIELDS = 19

      attr_reader :connection

      def initialize(adapter = Faraday.default_adapter)
        @connection = connect!(adapter)
        connection.response :json, :content_type => /\bjson$/
      end

      def connect!(adapter)
        # TODO: why isn't this reading the config file correctly
        # Faraday.new host do |faraday|
        Faraday.new "http://securenanoark.com:9999" do |faraday|
          faraday.response :json, content_type: /\bjson$/
          faraday.use :http_cache, store: Rails.cache, logger: Rails.logger
          faraday.adapter(*adapter)
        end
      end

      def request_ocr(name, location, fields, logger = nil)

        #call to addimage
        addImage = "#{NANO_API_PATH}/addImage/#{name}"
        addImage += "/#{location}/1500/2193" #TODO: we want them to remove these params


        #call to addimagefields
        fields = fields.slice 0..MAX_FIELDS
        field_ids  = (0..MAX_FIELDS).to_a * NANO_DELIMITER
        addImageFields = "#{NANO_API_PATH}/addImageFields/#{name}"

        lefts   = (fields.collect { |field| field[:left].round   }) * NANO_DELIMITER
        tops    = (fields.collect { |field| field[:top].round    }) * NANO_DELIMITER
        heights = (fields.collect { |field| field[:height].round }) * NANO_DELIMITER
        widths  = (fields.collect { |field| field[:width].round  }) * NANO_DELIMITER

        addImageFields += "/#{field_ids}/#{lefts}/#{tops}/#{heights}/#{widths}/0.2/0.8" #TODO: remove params

        logger.info "Attempting to add image: #{addImage}" if logger
        resp = connection.get(addImage) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end

        #TODO: something else if we don't get a 200
        #TODO: rescue exceptions

        logger.info "Attempting to add fields: #{addImageFields}" if logger
        resp = connection.get(addImageFields) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end

        resp
        #TODO: something else if we don't get a 200
        #TODO: rescue exceptions
      end

      def check_ocr_progress(name, logger = nil)
        request = "#{NANO_API_PATH}/isImageOCRed/#{name}"

        logger.info "checking #{request}" if logger

        connection.get(request) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end
      end

      def fetch_ocr(name, subject_id, logger = nil)
        request = "#{NANO_API_PATH}/getImageFields/#{name}"

        logger.info "fetching #{request}" if logger

        connection.get(request) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end
      end

    end
  end
end
