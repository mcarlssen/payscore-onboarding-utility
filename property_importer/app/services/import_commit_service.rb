# frozen_string_literal: true

class ImportCommitService
  def initialize(import_session)
    @session = import_session
  end

  def call
    return { ok: false, error: "Session already committed" } unless @session.draft?

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
        prop ||= Property.create!(
          building_name: first.building_name,
          street_address: first.street_address,
          city: first.city,
          state: first.state,
          zip_code: first.zip_code
        )
        rows.each do |row|
          next unless row.unit_number_present? && !row.skip_unit
          Unit.find_or_create_by!(property_id: prop.id, unit_number: row.unit_number.to_s.strip)
        end
      end
      @session.update!(status: "committed")
      { ok: true }
    end
  rescue ActiveRecord::RecordInvalid => e
    @session.update!(status: "failed")
    { ok: false, error: e.message }
  end
  rescue StandardError => e
    @session.update!(status: "failed") if @session.draft?
    { ok: false, error: e.message }
  end

  private

  def staged_property_groups
    @session.staged_rows.reload.order(:row_number).group_by(&:property_key)
  end
end
