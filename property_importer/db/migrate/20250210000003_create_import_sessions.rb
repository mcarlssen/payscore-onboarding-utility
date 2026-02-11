# frozen_string_literal: true

class CreateImportSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :import_sessions do |t|
      t.string :status, null: false, default: "draft"
      t.string :file_name

      t.timestamps
    end
  end
end
