Rails.application.routes.draw do

  use_doorkeeper
  namespace :api, defaults: { format: :json } do

    scope module: :v1 do

      get "/NanoWeather/:action(/:id)", to: "nano_weather"

    end

  end

end
