# frozen_string_literal: true

Rails.application.routes.draw do
  get :forms, to: 'forms#landing'
  get 'forms/basic', to: 'forms#basic'

  get :combobox, to: 'combobox#landing'
  get 'combobox/basic', to: 'combobox#basic'
  get 'combobox/multi_select', to: 'combobox#multi_select'
  get 'combobox/async', to: 'combobox#async'
  get 'combobox/users', to: 'combobox#users'

  get :breadcrumbs, to: 'breadcrumbs#landing'
  get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
  get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'

  scope path: :bare, as: :bare do
    get 'forms/basic', to: 'forms#basic'

    get 'combobox/basic', to: 'combobox#basic'
    get 'combobox/multi_select', to: 'combobox#multi_select'
    get 'combobox/async', to: 'combobox#async'

    get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
    get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'
  end

  root to: 'home#index'
end
