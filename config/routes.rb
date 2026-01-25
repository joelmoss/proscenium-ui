# frozen_string_literal: true

Rails.application.routes.draw do
  get :forms, to: 'forms#index'
  get :breadcrumbs, to: 'breadcrumbs#index'

  scope path: :bare, as: :bare do
    get :breadcrumbs, to: 'breadcrumbs#index'
  end

  root to: 'home#index'
end
