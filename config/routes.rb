Rails.application.routes.draw do

  resources :users do
    post :cancel_registration, on: :member
  end

  get '/login/:role_description' => 'users#login', as: :demo_login, constraints: { role_description: /(doctor|staff)/ }
  get '/login/:id' => 'users#login', as: :login

  get '/logout' => 'users#logout'

  resources :patients do
    resources :prescriptions do
      resources :pa_requests
    end
  end

  resources :pa_requests do
    resource :request_pages, only: [:show]
  end

  post '/pa_requests/:pa_request_id/request_pages/:button_title',
    to: 'request_pages#do_action',
    as: :pa_request_request_pages_action

  get '/toggle_ui', to: 'home#toggle_custom_ui'

  get '/dashboard' => 'pa_requests#index'

  get '/help' => 'home#help'

  get '/api' => redirect("https://developers.covermymeds.com/#overview"),
    as: :api_documentation

  get '/code' => redirect("https://github.com/covermymeds/demo-ehr-rails"),
    as: :source_code

  resources :cmm_callbacks, only: [:create, :index, :show]

  get '/home' => 'home#home', as: :home
  put '/home/change_api_env' => 'home#change_api_env'
  put '/home/resetdb' => 'home#reset_database', as: :reset_db

  root 'home#index'

  post '/pa_required' => 'formularies#pa_required'

end
