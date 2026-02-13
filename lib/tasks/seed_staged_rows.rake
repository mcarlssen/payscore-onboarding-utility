# frozen_string_literal: true

namespace :db do
  desc "Load staged rows seed data from db/seeds_staged_rows.sql (run after db:seed_baseline)"
  task seed_staged_rows: :environment do
    sql = File.read(Rails.root.join("db", "seeds_staged_rows.sql"))
    sql = sql.delete_prefix("\uFEFF")  # Strip UTF-8 BOM if present (common on Windows)
    ActiveRecord::Base.connection.execute(sql)
    puts "Loaded db/seeds_staged_rows.sql"
  end
end
