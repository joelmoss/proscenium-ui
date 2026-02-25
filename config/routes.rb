# frozen_string_literal: true

Rails.application.routes.draw do
  get :forms, to: 'forms#index'
  get :breadcrumbs, to: 'breadcrumbs#index'
  get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'

  scope path: :bare, as: :bare do
    get :breadcrumbs, to: 'breadcrumbs#index'
    get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'
  end

  root to: 'home#index'
end
