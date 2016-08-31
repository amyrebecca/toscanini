module OldWeatherOCR
  class TestDriver

    include Sidekiq::Worker
    include Sidetiq::Schedulable

    sidekiq_options :retry => false

    recurrence do
      secondly(30)
    end

    def perform
      logger.debug "Checking for input CSV file"

      unless File.directory? "tmp/input"
        logger.warn "No input directory present"
        return
      end

      unless File.exist? "tmp/input/input.csv"
        logger.debug "No input file present"
        return
      end

      logger.debug "Processing input.csv"

      contents = nil
      file = File.open "tmp/input/input.csv","rb"

      begin
        contents = file.read
        file.close unless file.nil?

        File.rename("tmp/input/input.csv", "tmp/input/input.csv.#{Time.now.getutc.to_i}")
      rescue
        file.close unless file.nil?
        logger.warn "Failed to read csv file"
        return
      end

      logger.info "Processing input data"
      RequestOCR.perform_async 12345, 67890, "https://panoptes-uploads.zooniverse.org/staging/subject_location/416134c3-0650-4414-9e05-7ea0c600ee4e.jpeg", contents

      begin
      rescue NotImplementedError => ex
        logger.warn "Could not process CSV: #{ex.to_s}"
      end

    end

  end
end
