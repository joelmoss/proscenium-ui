# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'form' => 'forms#index'
  get 'breadcrumbs' => 'breadcrumbs#index'
  get 'flash' => 'flash#index'

  # Tests ---
  resources :users
  get '/events' => 'users#index'

  root to: 'home#index'
end
