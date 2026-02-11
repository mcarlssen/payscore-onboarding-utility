# frozen_string_literal: true

class Property < ApplicationRecord
  has_many :units, dependent: :destroy

  validates :building_name, :street_address, :city, :state, :zip_code, presence: true
  validates :building_name, uniqueness: { scope: %i[street_address city state zip_code] }

  def self.find_by_composite(building_name:, street_address:, city:, state:, zip_code:)
    find_by(
      building_name: building_name.to_s.strip,
      street_address: street_address.to_s.strip,
      city: city.to_s.strip,
      state: state.to_s.strip,
      zip_code: zip_code.to_s.strip
    )
  end
end
