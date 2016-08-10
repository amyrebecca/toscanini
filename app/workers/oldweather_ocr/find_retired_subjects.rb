require 'sidetiq'

module Toscanini
  module Workers
    module OldWeatherOCR
      class FindRetiredSubjects < ConfigurableWorker

        include Sidetiq::Schedulable

        attr_reader :client

        OldWeatherGridWorkflowId = 1234

        def initialize()
          panoptes_config = load_config("panoptes.yml", "development")
          # TODO: shouldn't the panoptes service object know how to load its own config?
          @client = Toscanini::Services::Panoptes.new(panoptes_config.fetch("url"),
                                                 panoptes_config.fetch("client_id"),
                                                 panoptes_config.fetch("client_secret"))
        end

        recurrence do
          # hourly(1)
          minutely(5)
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

          # testing purposes
          RequestAggregation.perform_async OldWeatherGridWorkflowId, 4
        end

      end
    end
  end
end
