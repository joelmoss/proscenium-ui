# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users
  get '/events' => 'users#index'
  root to: 'home#index'
end
