# frozen_string_literal: true

class AddSkipPropertyToStagedRows < ActiveRecord::Migration[7.2]
  def change
    add_column :staged_rows, :skip_property, :boolean, default: false, null: false
  end
end
