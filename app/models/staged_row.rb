# frozen_string_literal: true

class StagedRow < ApplicationRecord
  belongs_to :import_session

  # row_number is always set by the parser. Address fields (building_name, street_address, city, state, zip_code)
  # are validated in run_validations/CsvImportParser and stored in validation_errors—we allow blanks here
  # so the import can stage all rows and show errors on the preview page instead of raising 422.
  validates :row_number, presence: true

  def unit_number_present?
    unit_number.present? && unit_number.to_s.strip.present?
  end

  def property_key
    ::AddressNormalizer.normalize_key(
      building_name: building_name,
      street_address: street_address,
      city: city,
      state: state,
      zip_code: zip_code
    )
  end

  # Returns condensed validation message, e.g. "Building Name, City required"
  def formatted_validation_errors
    return "" unless validation_errors.present?
    errs = JSON.parse(validation_errors) rescue []
    return "" if errs.empty?
    required_fields = errs.select { |m| m.to_s.end_with?(" required") }.map { |m| m.to_s.sub(/\s+required\z/, "") }
    if required_fields.size == errs.size && required_fields.any?
      "#{required_fields.join(", ")} required"
    else
      errs.join("; ")
    end
  end

  # Returns attribute names (e.g. :building_name) that have validation errors
  def attributes_with_errors
    return [] unless validation_errors.present?
    errs = JSON.parse(validation_errors) rescue []
    errs.flat_map do |msg|
      case msg
      when /building\s*name/i then :building_name
      when /street\s*address/i then :street_address
      when /\bcity\b/i then :city
      when /\bstate\b/i then :state
      when /zip\s*code/i then :zip_code
      else nil
      end
    end.compact.uniq
  end
end
