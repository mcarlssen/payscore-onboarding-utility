# frozen_string_literal: true

class CreateStagedRows < ActiveRecord::Migration[7.2]
  def change
    create_table :staged_rows do |t|
      t.references :import_session, null: false, foreign_key: true
      t.integer :row_number, null: false
      t.string :building_name, null: false
      t.string :street_address, null: false
      t.string :unit_number
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false
      t.text :validation_errors

      t.timestamps
    end
  end
end
