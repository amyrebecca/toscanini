module Toscanini
  module Workers
    module OldWeatherOCR
      class PollOCR < ConfigurableWorker

        attr_reader :client

        def initialize()
          @client = ::Toscanini::Services::Nanoweather.new()
        end

        def is_ready?(result)
          false
        end

        def perform(subject_id)
          begin
            result = client.check_ocr_progress subject_id
            if is_ready? result
              ProcessOCRResult.perform_async subject_id
            else
              sleep 5
              PollOCR.perform_async subject_id
            end
          rescue Exception => ex
          end
        end

      end
    end
  end
end
