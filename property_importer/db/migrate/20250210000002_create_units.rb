# frozen_string_literal: true

class CreateUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :units do |t|
      t.references :property, null: false, foreign_key: true
      t.string :unit_number, null: false

      t.timestamps
    end

    add_index :units, %i[property_id unit_number], unique: true
  end
end
