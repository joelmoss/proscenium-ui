# frozen_string_literal: true

class FlashController < ApplicationController
  def basic
    flash.now[:notice] = 'This is a success notification.'
  end

  def types
    flash.now[:notice] = 'Something went well!'
    flash.now[:alert] = 'Something needs your attention.'
  end
end
