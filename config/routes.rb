# frozen_string_literal: true

Rails.application.routes.draw do
  get :forms, to: 'forms#landing'
  get 'forms/basic', to: 'forms#basic'

  get :combobox, to: 'combobox#landing'
  get 'combobox/basic', to: 'combobox#basic'
  get 'combobox/multi_select', to: 'combobox#multi_select'
  get 'combobox/async', to: 'combobox#async'
  get 'combobox/users', to: 'combobox#users'

  get :dropdown, to: 'dropdown#landing'
  get 'dropdown/basic', to: 'dropdown#basic'

  get :dropdown_menu, to: 'dropdown_menu#landing'
  get 'dropdown_menu/basic', to: 'dropdown_menu#basic'

  get :flash, to: 'flash#landing'
  get 'flash/basic', to: 'flash#basic'
  get 'flash/types', to: 'flash#types'

  get :badge, to: 'badge#landing'
  get 'badge/basic', to: 'badge#basic'
  get 'badge/variants', to: 'badge#variants'
  get 'badge/sizes', to: 'badge#sizes'

  get :breadcrumbs, to: 'breadcrumbs#landing'
  get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
  get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'

  scope path: :bare, as: :bare do
    get 'forms/basic', to: 'forms#basic'

    get 'combobox/basic', to: 'combobox#basic'
    get 'combobox/multi_select', to: 'combobox#multi_select'
    get 'combobox/async', to: 'combobox#async'

    get 'dropdown/basic', to: 'dropdown#basic'

    get 'dropdown_menu/basic', to: 'dropdown_menu#basic'

    get 'flash/basic', to: 'flash#basic'
    get 'flash/types', to: 'flash#types'

    get 'badge/basic', to: 'badge#basic'
    get 'badge/variants', to: 'badge#variants'
    get 'badge/sizes', to: 'badge#sizes'

    get 'breadcrumbs/basic', to: 'breadcrumbs#basic'
    get 'breadcrumbs/custom_css', to: 'breadcrumbs#custom_css'
  end

  namespace :test do
    get 'web_component/actions', to: 'web_component#actions'
    get 'web_component/targets', to: 'web_component#targets'
    get 'web_component/values', to: 'web_component#values'
    get 'web_component/events', to: 'web_component#events'
    get 'web_component/attributes', to: 'web_component#attributes'
  end

  root to: 'home#index'
end
