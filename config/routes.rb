require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  get '*path' => redirect('/')

  resources :wallets, constraints: { id: /[^\/]+/ } do
    collection do
      get 'top'
      get 'feed'
      get 'hefty'
      get 'deals'
    end
    member do
      get 'download'
      get 'refresh'
    end
  end

  resources :tokens
  
  get '/search', to: 'pages#search', as: 'search'
  get '/wallpaper', to: 'pages#wallpaper', as: 'wallpaper'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#shutdown"
end
