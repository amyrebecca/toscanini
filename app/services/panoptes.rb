# require 'panoptes/client'

module Toscanini
  module Services
    class Panoptes
      include Configurable

      attr_reader :client

      self.config_file = "panoptes"
      self.api_prefix = "panoptes"

      def initialize()
        # @client = ::Panoptes::Client.new(url: url, auth: {client_id: client_id, client_secret: client_secret})
        @client = nil
      end

      def retire(subject_state)
        client.retire_subject(subject_state.workflow_id, subject_state.subject_id)
      end

      def fetch_subject(subject_id)
        # TODO: when the gem implements this method, call it
        raise NotImplementedError, "Waiting for support in panoptes-client gem"
      end

      def fetch_retired(workflow_id)
        # TODO: when the gem implements this method, call it
        raise NotImplementedError, "Waiting for support in panoptes-client gem"
      end
    end
  end
end
