# frozen_string_literal: true

namespace :db do
  # Set SECRET_KEY_BASE before environment loads so production dump works without credentials
  task :ensure_secret_for_dump do
    ENV["SECRET_KEY_BASE"] ||= "dump" if ENV["RAILS_ENV"] == "production"
  end

  desc "Dump properties and units from DB to seeds_baseline.sql format (run with RAILS_ENV=production)"
  task dump_baseline: [:ensure_secret_for_dump, :environment] do
    conn = ActiveRecord::Base.connection

    output = []
    output << "-- Baseline data for Property & Unit importer testing."
    output << "-- Run after migrations: bin/rails db:seed_baseline"
    output << "-- Resets sequences so future inserts get correct IDs."
    output << ""

    props = conn.execute(
      "SELECT id, building_name, street_address, city, state, zip_code, created_at, updated_at FROM properties ORDER BY id"
    ).to_a

    if props.any?
      output << "-- Properties (#{props.count})"
      output << "INSERT INTO properties (id, building_name, street_address, city, state, zip_code, created_at, updated_at) VALUES"
      output << props.map { |r|
        "(%s, %s, %s, %s, %s, %s, %s, %s)" % [
          r["id"],
          conn.quote(r["building_name"]),
          conn.quote(r["street_address"]),
          conn.quote(r["city"]),
          conn.quote(r["state"]),
          conn.quote(r["zip_code"]),
          conn.quote(r["created_at"]),
          conn.quote(r["updated_at"])
        ]
      }.join(",\n")
      output << ";"
      output << ""
    end

    units = conn.execute(
      "SELECT property_id, unit_number, created_at, updated_at FROM units ORDER BY property_id, unit_number"
    ).to_a

    if units.any?
      output << "-- Units (#{units.count})"
      output << "INSERT INTO units (property_id, unit_number, created_at, updated_at) VALUES"
      output << units.map { |r|
        "(%s, %s, %s, %s)" % [
          r["property_id"],
          conn.quote(r["unit_number"]),
          conn.quote(r["created_at"]),
          conn.quote(r["updated_at"])
        ]
      }.join(",\n")
      output << ";"
      output << ""
    end

    output << "-- Reset sequences for PostgreSQL"
    output << "SELECT setval(pg_get_serial_sequence('properties', 'id'), (SELECT COALESCE(MAX(id), 1) FROM properties));"
    output << "SELECT setval(pg_get_serial_sequence('units', 'id'), (SELECT COALESCE(MAX(id), 1) FROM units));"

    puts output.join("\n")
  end
end
