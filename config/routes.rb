require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  resources :wallets, constraints: { id: /[^\/]+/ } do
    collection do
      get 'top'
    end
    member do
      get 'download'
      get 'refresh'
    end
  end

  resources :tokens
  
  get '/search', to: 'pages#search', as: 'search'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#index"
end
