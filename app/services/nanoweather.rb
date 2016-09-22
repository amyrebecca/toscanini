require 'faraday'
# require 'cgi'

module Toscanini
  module Services
    class Nanoweather
      include Configurable

      self.config_file = "nanoweather"
      self.api_prefix = "nanoweather"

      NANO_API_PATH = "/NanoWeather/rest/NanoWeather"
      NANO_DELIMITER = "~"
      MAX_FIELDS = 135

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

        #TODO: add error handling

        #call to addimage
        # addImage = "#{NANO_API_PATH}/addImage/#{name}/#{CGI.escape location}"
        addImage = "#{NANO_API_PATH}/addImage/#{name}/#{location}"

        #call to addimagefields
        fields = fields.slice 0..MAX_FIELDS
        field_ids  = (0..MAX_FIELDS).to_a * NANO_DELIMITER
        addImageFields = "#{NANO_API_PATH}/addImageFields/#{name}"

        lefts   = (fields.collect { |field| field[:left]}) * NANO_DELIMITER
        tops    = (fields.collect { |field| field[:top]}) * NANO_DELIMITER
        heights = (fields.collect { |field| field[:height]}) * NANO_DELIMITER
        widths  = (fields.collect { |field| field[:width]}) * NANO_DELIMITER

        addImageFields += "/#{field_ids}/#{lefts}/#{tops}/#{heights}/#{widths}"

        logger.info "Attempting to add image: #{addImage}" if logger
        resp = connection.get(addImage) do |req|
          req.headers["Accept"] = "text/plain"
          # req.headers["Accept"] = "application/json"
          # req.headers["Content-Type"] = "application/json"
        end
        # logger.info "HTTP #{resp.status} #{resp.body}" unless resp.status == 200

        logger.info "sleeping, work fast!"
        sleep 30

        logger.info "Attempting to add fields: #{addImageFields}" if logger
        resp = connection.get(addImageFields) do |req|
          req.headers["Accept"] = "text/plain"
          # req.headers["Accept"] = "application/json"
          # req.headers["Content-Type"] = "application/json"
        end
        logger.info "HTTP #{resp.status} #{resp.body}" unless resp.status == 200

        resp
      end

      def check_ocr_progress(name, logger = nil)
        request = "#{NANO_API_PATH}/isImageOCRed/#{name}"

        logger.info "checking #{request}" if logger

        resp = connection.get(request) do |req|
          req.headers["Accept"] = "text/plain"
        end
        logger.info "HTTP #{resp.status} #{resp.body}" unless resp.status == 200

        resp
      end

      def fetch_ocr(name, subject_id, logger = nil)
        request = "#{NANO_API_PATH}/getImageFields/#{name}"

        resp = connection.get(request) do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
        end
        logger.info "HTTP #{resp.status} #{resp.body}" unless resp.status == 200

        resp
      end

      #TODO: deprecate when getImageFields is correct
      def fetch_ocrval(name, fieldname, logger = nil)
        request = "#{NANO_API_PATH}/getImageFieldOCRVal/#{name}/#{fieldname}"

        resp = connection.get(request) do |req|
          req.headers["Accept"] = "text/plain"
          # req.headers["Accept"] = "application/json"
          # req.headers["Content-Type"] = "application/json"
        end
        logger.info "HTTP #{resp.status} #{resp.body}" unless resp.status == 200

        resp
      end

      #TODO: deprecate when getImageFields is correct
      def fetch_confidence(name, fieldname, logger = nil)
        request = "#{NANO_API_PATH}/getImageFieldConfidence/#{name}/#{fieldname}"

        resp = connection.get(request) do |req|
          req.headers["Accept"] = "text/plain"
          # req.headers["Accept"] = "application/json"
          # req.headers["Content-Type"] = "application/json"
        end
        logger.info "HTTP #{resp.status} #{resp.body}" unless resp.status == 200

        resp
      end

    end
  end
end
