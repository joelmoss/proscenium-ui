# frozen_string_literal: true

class ComboboxController < ApplicationController
  USERS = [
    { label: 'Alice', value: '1' },
    { label: 'Alicia', value: '2' },
    { label: 'Bob', value: '3' },
    { label: 'Charlie', value: '4' },
    { label: 'Diana', value: '5' },
    { label: 'Eve', value: '6' },
    { label: 'Frank', value: '7' },
    { label: 'Grace', value: '8' }
  ].freeze

  def users
    term = params[:q].to_s.downcase
    results = USERS.select { |u| u[:label].downcase.include?(term) }
    render json: results
  end
end
