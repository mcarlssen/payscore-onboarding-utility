# frozen_string_literal: true

namespace :db do
  desc "Dump import_sessions and staged_rows from DB to SQL format (run with RAILS_ENV=production)"
  task dump_staged_rows: [:ensure_secret_for_dump, :environment] do
    conn = ActiveRecord::Base.connection

    output = []
    output << "-- Staged rows seed data (import_sessions + staged_rows)."
    output << "-- Run after migrations: load via SQL or db:seed_staged_rows."
    output << "-- Resets sequences so future inserts get correct IDs."
    output << ""

    sessions = conn.execute(
      "SELECT id, status, file_name, created_at, updated_at FROM import_sessions ORDER BY id"
    ).to_a

    if sessions.any?
      output << "-- Import sessions (#{sessions.count})"
      output << "INSERT INTO import_sessions (id, status, file_name, created_at, updated_at) VALUES"
      output << sessions.map { |r|
        "(%s, %s, %s, %s, %s)" % [
          r["id"],
          conn.quote(r["status"]),
          conn.quote(r["file_name"]),
          conn.quote(r["created_at"]),
          conn.quote(r["updated_at"])
        ]
      }.join(",\n")
      output << ";"
      output << ""
    end

    rows = conn.execute(
      "SELECT id, import_session_id, row_number, building_name, street_address, unit_number, city, state, zip_code, validation_errors, created_at, updated_at, skip_unit, skip_property FROM staged_rows ORDER BY import_session_id, row_number"
    ).to_a

    if rows.any?
      output << "-- Staged rows (#{rows.count})"
      output << "INSERT INTO staged_rows (id, import_session_id, row_number, building_name, street_address, unit_number, city, state, zip_code, validation_errors, created_at, updated_at, skip_unit, skip_property) VALUES"
      output << rows.map { |r|
        "(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)" % [
          r["id"],
          r["import_session_id"],
          r["row_number"],
          conn.quote(r["building_name"]),
          conn.quote(r["street_address"]),
          conn.quote(r["unit_number"]),
          conn.quote(r["city"]),
          conn.quote(r["state"]),
          conn.quote(r["zip_code"]),
          conn.quote(r["validation_errors"]),
          conn.quote(r["created_at"]),
          conn.quote(r["updated_at"]),
          conn.quote(r["skip_unit"]),
          conn.quote(r["skip_property"])
        ]
      }.join(",\n")
      output << ";"
      output << ""
    end

    output << "-- Reset sequences for PostgreSQL"
    output << "SELECT setval(pg_get_serial_sequence('import_sessions', 'id'), (SELECT COALESCE(MAX(id), 1) FROM import_sessions));"
    output << "SELECT setval(pg_get_serial_sequence('staged_rows', 'id'), (SELECT COALESCE(MAX(id), 1) FROM staged_rows));"

    puts output.join("\n")
  end
end
