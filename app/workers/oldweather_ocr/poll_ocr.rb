module Toscanini
  module Workers
    module OldWeatherOCR
      class PollOCR

        include Sidekiq::Worker

        sidekiq_options :retry => false

        attr_reader :client

        def initialize()
          @client = ::Toscanini::Services::Nanoweather.new()
        end

        def is_ready?(result)
          false
        end

        def perform(name, subject_id)
          begin
            result = client.check_ocr_progress name
            if is_ready? result
              ProcessOCRResult.perform_async name, subject_id
            else
              self.class.perform_in(30.seconds, name, subject_id)
            end
          rescue Exception => ex
            #TODO: probably log something sensible here
          end
        end

      end
    end
  end
end
