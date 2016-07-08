require 'sidekiq'
require 'yaml'

module Toscanini
  module Workers
    class ConfigurableWorker

      include Sidekiq::Worker

      def config_path(filename)
        File.expand_path(File.join('..', '..', '..', 'config', filename), __FILE__)
      end

      def load_config(filename, environment)
        path = config_path(filename)
        YAML.load_file(path).fetch(environment.to_s)
      end

    end
  end
end
