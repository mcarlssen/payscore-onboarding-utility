# frozen_string_literal: true

module AddressNormalizer
  # Strip all punctuation except dash (-). Uppercase for comparison.
  # Used for property grouping, conflict detection, and matching.
  def self.normalize(str)
    return "" if str.blank?
    # Remove all chars except alphanumeric, spaces, and dash; collapse whitespace
    # In the production app, this should be tightened up a lot - fractional addresses, ampersands, hash/pound symbols, etc. are valid address characters.
    # Not worth the effort to implement this for the MVP but would be necessary for real production.
    str.to_s.strip.upcase.gsub(/[^A-Z0-9\s\-\']/i, "")
  end

  def self.normalize_key(building_name:, street_address:, city:, state:, zip_code:)
    [
      normalize(building_name),
      normalize(street_address),
      normalize(city),
      normalize(state),
      normalize(zip_code)
    ]
  end
end
