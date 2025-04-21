# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'form' => 'forms#index'

  # Tests ---
  resources :users
  get '/events' => 'users#index'

  # Defines the root path route ("/")
  # root "posts#index"
end
