require 'sidetiq'

module OldWeatherOCR
  class FindRetiredSubjects

    include Sidekiq::Worker
    include Sidetiq::Schedulable

    # nothing that runs on a timer should get retried by sidekiq
    sidekiq_options :retry => false

    attr_reader :client

    OldWeatherGridWorkflowId = 1234

    def initialize()
      panoptes_config = load_config("panoptes.yml", "development")
      # TODO: shouldn't the panoptes service object know how to load its own config?
      # @client = Toscanini::Services::Panoptes.new(panoptes_config.fetch("url"),
      #                                        panoptes_config.fetch("client_id"),
      #                                        panoptes_config.fetch("client_secret"))
      @client = nil
    end

    recurrence do
      hourly(1)
    end

    def perform
      logger.debug "Looking for retired subjects in workflow #{OldWeatherGridWorkflowId}"

      begin
        retirees = client.fetch_retired OldWeatherGridWorkflowId #, lastTimestamp

        retirees.each do | subject |
          RequestAggregation.perform_async subject, OldWeatherGridWorkflowId
        end
      rescue NotImplementedError => ex
        logger.warn "Could not process retired subjects: #{ex.to_s}"
      end

    end

  end
end
