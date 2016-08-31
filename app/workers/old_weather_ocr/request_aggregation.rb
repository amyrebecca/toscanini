module OldWeatherOCR
  class RequestAggregation

    include Sidekiq::Worker

    attr_reader :client

    # TODO: obviously we're gonna need a config file setting for where this lives
    ToscaniniCallbackEndpoint = "http://localhost:3000/"

    def initialize()
      @client = Toscanini::Services::PanoptesAggregation.new()
    end

    def perform(subject, workflow_id)
      return unless subject && subject.id

      logger.debug "requesting aggregation for subject #{subject.id} in workflow #{workflow_id}"

      begin
        client.aggregate_subject subject, workflow_id, ToscaniniCallbackEndpoint
        # note that processing will resume from this point when the aggregation web service
        # calls our web service back with the aggregation results
      rescue NotImplementedError => ex
        logger.warn "Could not request aggregation for retired subject #{subject.id} in workflow #{workflow_id}: #{ex.to_s}"
      end
    end

  end
end
