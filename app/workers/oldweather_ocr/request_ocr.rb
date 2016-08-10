module Toscanini
  module Workers
    module OldWeatherOCR
      class RequestOCR < ConfigurableWorker

        attr_reader :nano_client
        attr_reader :panoptes_client

        def initialize()
          @nano_client = ::Toscanini::Services::Nanoweather.new()
          @panoptes_client = ::Toscanini::Services::Panoptes.new()
        end

        def perform(subject_id, workflow_id, aggregation_results=nil)
          logger.info "OCR-ing subject #{subject_id}"

          return unless aggregation_results # TODO: log that something went wrong

          subject = panoptes_client.fetch_subject(subject_id)
          location = subject.locations[0][subject.locations[0].keys.first]
          rows = parse aggregation_results
          fields = []

          # build field hashes for each row with enough matches
          rows.each do | row |
            next if row[:boxes_in_cluster] < 5
            fields.push (pluck row)
          end

          begin
            # ask nanoweather to ocr the fields
            ocr_name = "ocr_#{subject_id}_#{workflow_id}"
            nano_client.request_ocr ocr_name, location, fields

            # check every so often to see when the request is done
            PollOCR.perform_async ocr_name
          rescue NotImplementedError => ex
            logger.warn "Failed to request OCR of subject #{name}: #{ex.to_s}"
          rescue Exception => ex
            # TODO: rescue more specific errors
            logger.warn "Failed to request OCR of subject #{name}: #{ex.to_s}"
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
          csv = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
          csv.to_a.map {|row| row.to_hash }
        end

      end
    end
  end
end
