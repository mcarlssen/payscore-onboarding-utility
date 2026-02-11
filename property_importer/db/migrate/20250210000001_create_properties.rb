# frozen_string_literal: true

class CreateProperties < ActiveRecord::Migration[7.2]
  def change
    create_table :properties do |t|
      t.string :building_name, null: false
      t.string :street_address, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false

      t.timestamps
    end

    add_index :properties,
              %i[building_name street_address city state zip_code],
              unique: true,
              name: "index_properties_on_composite_identity"
  end
end
