require 'faraday'

module Toscanini
  module Services
    class PanoptesAggregation
      include Configurable

      self.config_file = "aggregation"
      self.api_prefix = "aggregation"

      attr_reader :connection

      def initialize(adapter = Faraday.default_adapter)
        @connection = connect!(adapter)
        connection.response :json, :content_type => /\bjson$/
      end

      def connect!(adapter)
        Faraday.new host do |faraday|
          faraday.response :json, content_type: /\bjson$/
          faraday.use :http_cache, store: Rails.cache, logger: Rails.logger
          faraday.adapter(*adapter)
        end
      end

      def generate_token
        Doorkeeper::AccessToken.create! do |ac|
          ac.resource_owner_id = user_id
          ac.application_id = application_id
          ac.expires_in = 1.day
          ac.scopes = "medium project public"
        end
      end

      def body(subject, location)
        {
          project_id: subject.links.project,
          medium_href: location,
          metadata: subject.metadata,
          token: generate_token.token
        }
      end

      def aggregate_subject(subject, workflow_id, callback_url = "")
        subject_id = subject.id
        connection.post("/subjects/#{subject_id}/aggregate") do |req|
          req.headers["Accept"] = "application/json"
          req.headers["Content-Type"] = "application/json"
          b = body(subject, callback_url)
          b.workflow_id = workflow_id
          req.body = b.to_json
        end
      end

    end
  end
end
