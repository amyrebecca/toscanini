require 'csv'

module OldWeatherOCR
  class RequestOCR

    include Sidekiq::Worker

    attr_reader :nano_client

    def initialize()
      @nano_client = ::Toscanini::Services::Nanoweather.new()
    end

    def perform(subject_id, workflow_id, location, aggregation_results=nil)

      logger.info "OCR-ing subject #{subject_id}"

      begin
        rows = parse aggregation_results
        fields = []

        # build field hashes for each row with enough matches
        rows.each do | row |
          next if row[:boxes_in_cluster] < 5
          fields.push (pluck row)
        end

        # ask nanoweather to ocr the fields
        ocr_name = "zooniverse_#{subject_id}_#{workflow_id}_#{Time.now.getutc.to_i}"
        logger.info "Requesting OCR for #{ocr_name}"
        nano_client.request_ocr ocr_name, location, fields, logger

        # check every so often to see when the request is done
        PollOCR.perform_in(30.seconds, ocr_name, subject_id)

      rescue Exception => ex
        logger.warn "Failed to request OCR of subject #{ocr_name}: #{ex.to_s}"
        raise
      end

    end

    def pluck(row)
      {
        top: row[:agg_tl_y],
        left: row[:agg_tl_x],
        width: row[:agg_width],
        height: row[:agg_height]
      }
    end

    def parse(aggregation_result=nil)
      CSV::Converters[:blank_to_nil] = lambda do |field|
        field && field.empty? ? nil : field
      end
      csv = CSV.new(aggregation_result, :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
      csv.to_a.map {|row| row.to_hash }
    end

  end
end
