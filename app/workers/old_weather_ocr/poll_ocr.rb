module OldWeatherOCR
  class PollOCR

    include Sidekiq::Worker

    # nothing that runs on a timer should get retried by sidekiq
    sidekiq_options :retry => false

    attr_reader :client

    def initialize()
      @client = ::Toscanini::Services::Nanoweather.new()
    end

    def is_ready?(response)
      response && response.body && response.body == "100"
    end

    def perform(name, subject_id)
      begin
        response = client.check_ocr_progress name, logger
        if is_ready? response
          ProcessOCRResult.perform_async name, subject_id
        else
          # nil
          self.class.perform_in(30.seconds, name, subject_id)
        end
      rescue Exception => ex
        #TODO: log exception
        # nil
        self.class.perform_in(30.seconds, name, subject_id)
      end
    end

  end
end
