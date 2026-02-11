# frozen_string_literal: true

class StagedRow < ApplicationRecord
  belongs_to :import_session

  validates :row_number, :building_name, :street_address, :city, :state, :zip_code, presence: true

  def unit_number_present?
    unit_number.present? && unit_number.to_s.strip.present?
  end

  def property_key
    [
      building_name.to_s.strip,
      street_address.to_s.strip,
      city.to_s.strip,
      state.to_s.strip,
      zip_code.to_s.strip
    ]
  end
end
