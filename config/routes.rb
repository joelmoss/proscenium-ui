# frozen_string_literal: true

Rails.application.routes.draw do
  get :forms, to: 'forms#landing'
  get 'forms/basic', to: 'forms#basic'

  get :combobox, to: 'combobox#landing'
  get 'combobox/basic', to: 'combobox#basic'
  get 'combobox/multi_select', to: 'combobox#multi_select'
  get 'combobox/async', to: 'combobox#async'
  get 'combobox/users', to: 'combobox#users'

  get :flash, to: 'flash#landing'
  get 'flash/basic', to: 'flash#basic'
  get 'flash/types', to: 'flash#types'

  get :badge, to: 'badge#landing'
  get 'badge/basic', to: 'badge#basic'
  get 'badge/types', to: 'badge#types'
  get 'badge/sizes', to: 'badge#sizes'

  get :breadcrumbs, to: 'breadcrumbs#landing'
  get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
  get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'

  scope path: :bare, as: :bare do
    get 'forms/basic', to: 'forms#basic'

    get 'combobox/basic', to: 'combobox#basic'
    get 'combobox/multi_select', to: 'combobox#multi_select'
    get 'combobox/async', to: 'combobox#async'

    get 'flash/basic', to: 'flash#basic'
    get 'flash/types', to: 'flash#types'

    get 'badge/basic', to: 'badge#basic'
    get 'badge/types', to: 'badge#types'
    get 'badge/sizes', to: 'badge#sizes'

    get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
    get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'
  end

  root to: 'home#index'
end
