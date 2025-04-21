# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :user, optional: true
  def to_s
    name
  end
end
