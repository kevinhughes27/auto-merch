require 'sidekiq/web'

Rails.application.routes.draw do

  controller :sessions do
    get 'login' => :new, :as => :login
    post 'login' => :create, :as => :authenticate
    get 'auth/shopify/callback' => :callback
    get 'logout' => :destroy, :as => :logout
  end

  root :to => 'shops#show'

  resources :shops

  mount Sidekiq::Web => '/sidekiq'
end
