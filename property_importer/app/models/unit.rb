# frozen_string_literal: true

class Unit < ApplicationRecord
  belongs_to :property

  validates :unit_number, presence: true
  validates :unit_number, uniqueness: { scope: :property_id }
end
