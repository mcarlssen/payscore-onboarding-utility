# frozen_string_literal: true

class AddSkipUnitToStagedRows < ActiveRecord::Migration[7.2]
  def change
    add_column :staged_rows, :skip_unit, :boolean, default: false, null: false
  end
end
