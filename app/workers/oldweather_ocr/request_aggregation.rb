module Toscanini
  module Workers
    module OldWeatherOCR
      class RequestAggregation < ConfigurableWorker

        attr_reader :client

        # TODO: obviously we're gonna need a config file setting for where this lives
        ToscaniniCallbackEndpoint = "http://localhost:3000/"

        def initialize()
          aggregation_config = load_config("aggregation.yml", "development")
          # TODO: move to aggregation service constructor
          @client = Toscanini::Services::PanoptesAggregation.new(aggregation_config.fetch("host"),
                                                 aggregation_config.fetch("user"),
                                                 aggregation_config.fetch("application"))
        end

        def perform(workflow_id, subject_id)
          logger.debug "requesting aggregation for subject #{subject_id} in workflow #{workflow_id}"

          begin
            client.aggregate_subject workflow_id, subject_id, ToscaniniCallbackEndpoint
          rescue NotImplementedError => ex
            logger.warn "Could not request aggregation for retired subject #{subject_id} in workflow #{workflow_id}: #{ex.to_s}"
          end

          # testing purposes
          RequestOCR.perform_async "file name", 8
        end

      end
    end
  end
end
