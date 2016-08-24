Rails.application.routes.draw do

  use_doorkeeper
  namespace :api, defaults: { format: :json } do

    scope module: :v1 do

    end
    
  end

end
