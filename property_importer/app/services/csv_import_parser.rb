# frozen_string_literal: true

require "csv"

class CsvImportParser
  EXPECTED_HEADERS = ["Building Name", "Street Address", "Unit", "City", "State", "Zip Code"].freeze
  HEADER_MAP = {
    "Building Name" => "building_name",
    "Street Address" => "street_address",
    "Unit" => "unit_number",
    "City" => "city",
    "State" => "state",
    "Zip Code" => "zip_code"
  }.freeze

  ParseError = Class.new(StandardError)

  def initialize(csv_content:, file_name: nil)
    @csv_content = csv_content
    @file_name = file_name
  end

  def parse_into_session(session)
    rows = parse
    rows.each_with_index do |row, i|
      session.staged_rows.create!(
        row_number: i + 2,
        building_name: row["building_name"].to_s.strip,
        street_address: row["street_address"].to_s.strip,
        unit_number: row["unit_number"].to_s.strip.presence,
        city: row["city"].to_s.strip,
        state: row["state"].to_s.strip,
        zip_code: row["zip_code"].to_s.strip
      )
    end
    run_validations(session)
  end

  def parse
    csv = CSV.parse(@csv_content, headers: true)
    unless (csv.headers & EXPECTED_HEADERS).size == EXPECTED_HEADERS.size
      raise ParseError, "Expected headers: #{EXPECTED_HEADERS.join(', ')}. Got: #{csv.headers.inspect}"
    end
    out = []
    csv.each.with_index(2) do |row, line_num|
      h = {}
      HEADER_MAP.each do |header, key|
        val = row[header]&.to_s
        h[key] = val
      end
      next if row_blank?(h)
      out << h
    end
    out
  rescue CSV::MalformedCSVError => e
    raise ParseError, "Invalid CSV: #{e.message}"
  end

  private

  def row_blank?(h)
    %w[building_name street_address city state zip_code].all? { |k| h[k].to_s.strip.blank? }
  end

  def run_validations(session)
    session.staged_rows.reload.each do |row|
      errs = []
      errs << "Building Name required" if row.building_name.to_s.strip.upcase.blank?
      errs << "Street Address required" if row.street_address.to_s.strip.upcase.blank?
      errs << "City required" if row.city.to_s.strip.upcase.blank?
      errs << "State required" if row.state.to_s.strip.upcase.blank?
      errs << "Zip Code required" if row.zip_code.to_s.strip.upcase.blank?
      row.update_column(:validation_errors, errs.presence&.to_json)
    end
  end
end
