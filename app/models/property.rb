# frozen_string_literal: true

class Property < ApplicationRecord
  has_many :units, dependent: :destroy

  validates :building_name, :street_address, :city, :state, :zip_code, presence: true
  validates :building_name, uniqueness: { scope: %i[street_address city state zip_code] }

  def self.find_by_composite(building_name:, street_address:, city:, state:, zip_code:)
    search_key = ::AddressNormalizer.normalize_key(
      building_name: building_name,
      street_address: street_address,
      city: city,
      state: state,
      zip_code: zip_code
    )
    all.find do |p|
      ::AddressNormalizer.normalize_key(
        building_name: p.building_name,
        street_address: p.street_address,
        city: p.city,
        state: p.state,
        zip_code: p.zip_code
      ) == search_key
    end
  end
end
