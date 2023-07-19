Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :audio_recording, only: [:index, :show, :create, :update]
      get '/health_check', to: proc { [200, {}, ['success']] }
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
