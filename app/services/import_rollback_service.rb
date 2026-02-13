# frozen_string_literal: true

class ImportRollbackService
  def initialize(import_session)
    @session = import_session
  end

  def call
    return { ok: false, error: "Only committed imports can be rolled back" } unless @session.committed?

    ActiveRecord::Base.transaction do
      grouped = staged_property_groups
      grouped.each do |_key, rows|
        next if rows.empty?
        next if rows.any?(&:skip_property?)
        first = rows.first
        prop = Property.find_by_composite(
          building_name: first.building_name,
          street_address: first.street_address,
          city: first.city,
          state: first.state,
          zip_code: first.zip_code
        )
        next unless prop

        rows.each do |row|
          next unless row.unit_number_present? && !row.skip_unit
          unit_num = row.unit_number.to_s.strip
          prop.units.find_by(unit_number: unit_num)&.destroy!
        end

        prop.reload
        prop.destroy! if prop.units.empty?
      end
      @session.update!(status: "rolled_back")
      { ok: true }
    end
  rescue StandardError => e
    @session.update!(status: "failed") if @session.committed?
    { ok: false, error: e.message }
  end

  private

  def staged_property_groups
    @session.staged_rows.reload.order(:row_number).group_by(&:property_key)
  end
end
