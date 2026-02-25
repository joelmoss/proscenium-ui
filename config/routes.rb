# frozen_string_literal: true

Rails.application.routes.draw do
  get :forms, to: 'forms#landing'
  get 'forms/basic', to: 'forms#basic'

  get :breadcrumbs, to: 'breadcrumbs#landing'
  get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
  get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'

  scope path: :bare, as: :bare do
    get 'forms/basic', to: 'forms#basic'
    get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
    get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'
  end

  root to: 'home#index'
end
