# frozen_string_literal: true

namespace :db do
  desc "Seed a sample import session with staged rows from Sample_Import.csv (run after db:seed_baseline)"
  task seed_staged_rows: :environment do
    csv_path = Rails.root.join("..", "Sample_Import.csv")
    unless File.exist?(csv_path)
      abort "Sample_Import.csv not found at #{csv_path}. Ensure it exists in the assessment folder."
    end

    session = ImportSession.create!(status: "draft", file_name: "Sample_Import.csv")
    CsvImportParser.new(csv_content: File.read(csv_path), file_name: "Sample_Import.csv")
      .parse_into_session(session)

    puts "Seeded import session ##{session.id} with #{session.staged_rows.count} staged rows from Sample_Import.csv"
  end
end
