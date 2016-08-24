require 'faraday'

module Toscanini
  module Services
    class Nanoweather
      include Configurable

      self.config_file = "nanoweather"
      self.api_prefix = "nanoweather"

      NANO_API_PATH = "/Nanoweather/rest/Nanoweather"

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

      def request_ocr(name, location, fields, logger)

        #call to addimage
        request = "#{NANO_API_PATH}/addImage/#{name}"
        request += "/#{location}/1500/2193" #TODO: we want them to remove these params

        logger.info "Attempting to add image: #{request}"

        resp = connection.get(request) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end

        #TODO: something else if we don't get a 200
        #TODO: rescue exceptions

        #call to addimagefields
        fields = fields.slice 0..5
        field_ids  = (0..5).to_a * ";"
        request = "#{NANO_API_PATH}/addImageFields/#{name}"

        lefts   = (fields.collect { |field| field[:left].round   }) * ";"
        tops    = (fields.collect { |field| field[:top].round    }) * ";"
        heights = (fields.collect { |field| field[:height].round }) * ";"
        widths  = (fields.collect { |field| field[:width].round  }) * ";"

        request += "/#{field_ids}/#{lefts}/#{tops}/#{heights}/#{widths}/0.2/0.8" #TODO: remove params

        logger.info "Attempting to add fields: #{request}"

        resp = connection.get(request) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end

        resp
        #TODO: something else if we don't get a 200
        #TODO: rescue exceptions
      end

      def check_ocr_progress(name, subject_id)
        connection.get("#{NANO_API_PATH}/isImageOCRed/#{name}") do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end
      end

      def fetch_ocr(name, subject_id)
        connection.get("#{NANO_API_PATH}/getImageFields/#{name}") do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end
      end

    end
  end
end
