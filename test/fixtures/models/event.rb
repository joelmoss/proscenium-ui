# frozen_string_literal: true

class Event < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
  belongs_to :user, optional: true
end
