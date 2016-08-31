Rails.application.routes.draw do

  use_doorkeeper

  # following https://www.bignerdranch.com/blog/adding-versions-rails-api/
  namespace :api, defaults: { format: :json } do

    # scope module: :v1, constraints: ApiConstraint.new(version: 1) do
    scope module: :v1 do

      # post "/NanoWeather/:action/:id", controller: "nano_weather"
      post "/NanoWeather/:action/:subject_id/:workflow_id", controller: "nano_weather"

    end

  end

end
