# frozen_string_literal: true

namespace :db do
  desc "Load baseline seed data from db/seeds_baseline_dev.sql (run once after db:migrate)"
  task seed_baseline: :environment do
    sql = File.read(Rails.root.join("db", "seeds_baseline_dev.sql"))
    ActiveRecord::Base.connection.execute(sql)
    puts "Loaded db/seeds_baseline_dev.sql"
  end
end
