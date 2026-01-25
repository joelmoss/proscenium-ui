# frozen_string_literal: true

class User < ApplicationRecord
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :events
  has_one :address

  enum :gender, { male: 0, female: 1, other: 2 }, suffix: true
  enum :gender_with_db_default, { male: 0, female: 1, other: 2 }, suffix: true
  enum :gender_with_code_default, { male: 0, female: 1, other: 2 }, default: :female,
                                                                    suffix: true

  def to_s
    name
  end
end
