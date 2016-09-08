module OldWeatherOCR
  class PollOCR

    include Sidekiq::Worker

    # nothing that runs on a timer should get retried by sidekiq
    sidekiq_options :retry => false

    attr_reader :client

    def initialize()
      @client = ::Toscanini::Services::Nanoweather.new()
    end

    def is_ready?(result)
      # false
      true
    end

    def perform(name, subject_id)
      begin
        result = client.check_ocr_progress name, logger
        if is_ready? result
          ProcessOCRResult.perform_async name, subject_id
        else
          self.class.perform_in(30.seconds, name, subject_id)
        end
      rescue Exception => ex
        # self.class.perform_in(30.seconds, name, subject_id)
        raise
      end
    end

  end
end
