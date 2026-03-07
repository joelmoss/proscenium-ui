# frozen_string_literal: true

# rubocop:disable Rails/I18nLocaleTexts
class FlashController < ApplicationController
  def basic
    flash.now[:notice] = 'This is a success notification.'
  end

  def types
    flash.now[:notice] = 'Something went well!'
    flash.now[:alert] = 'Something needs your attention.'
  end
end
# rubocop:enable Rails/I18nLocaleTexts
