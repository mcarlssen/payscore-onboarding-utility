# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :set_import_session, only: %i[show preview preview_update conflicts conflicts_resolve summary confirm discard]

  def index
    @recent_sessions = ImportSession.includes(:staged_rows).order(created_at: :desc).limit(10)
  end

  def create
    file = params[:csv_file]
    unless file&.respond_to?(:read)
      flash[:alert] = "Please select a CSV file."
      return redirect_to root_path
    end

    session = ImportSession.create!(status: "draft", file_name: file.original_filename)
    parser = CsvImportParser.new(csv_content: file.read, file_name: file.original_filename)
    parser.parse_into_session(session)
    redirect_to preview_import_path(session), notice: "CSV uploaded. Review and fix rows below."
  rescue CsvImportParser::ParseError => e
    flash[:alert] = e.message
    redirect_to root_path
  end

  def show
    redirect_to preview_import_path(@import_session)
  end

  def preview
    @staged_rows = @import_session.staged_rows.order(:row_number)
    @has_errors = @staged_rows.any? { |r| r.validation_errors.present? }
  end

  def preview_update
    (params[:staged_rows] || {}).each do |id, attrs|
      row = @import_session.staged_rows.find_by(id: id)
      next unless row
      row.update(attrs.permit(:building_name, :street_address, :unit_number, :city, :state, :zip_code))
    end
    respond_to do |format|
      format.html { redirect_to preview_import_path(@import_session), notice: "Saved." }
      format.json { head :ok }
    end
  end

  def conflicts
    @conflicts = conflict_groups
  end

  def conflicts_resolve
    (params[:skip_property] || []).each do |key|
      # key is "building_name\taddress\tcity\tstate\tzip"
      parts = key.split("\t", 5)
      next if parts.size < 5
      @import_session.staged_rows.where(
        building_name: parts[0],
        street_address: parts[1],
        city: parts[2],
        state: parts[3],
        zip_code: parts[4]
      ).update_all(skip_unit: true, skip_property: true)
    end
    (params[:skip_unit] || []).each do |row_id|
      @import_session.staged_rows.where(id: row_id).update_all(skip_unit: true)
    end
    (params[:unskip_unit] || []).each do |row_id|
      @import_session.staged_rows.where(id: row_id).update_all(skip_unit: false)
    end
    redirect_to summary_import_path(@import_session), notice: "Conflict choices saved."
  end

  def summary
    @summary = build_summary
  end

  def discard
    unless @import_session.draft?
      redirect_to root_path, alert: "Only draft imports can be discarded."
      return
    end
    @import_session.destroy!
    redirect_to root_path, notice: "Import discarded."
  end

  def confirm
    if @import_session.committed?
      redirect_to properties_path, notice: "This import was already committed."
      return
    end
    result = ImportCommitService.new(@import_session).call
    if result[:ok]
      redirect_to properties_path, notice: "Import completed successfully."
    else
      flash[:alert] = result[:error]
      redirect_to summary_import_path(@import_session)
    end
  end

  private

  def set_import_session
    @import_session = ImportSession.find(params[:id])
  end

  def conflict_groups
    groups = @import_session.staged_rows.reload.order(:row_number).group_by(&:property_key)
    conflicts = []
    groups.each do |key, rows|
      next if rows.empty?
      first = rows.first
      existing = Property.find_by_composite(
        building_name: first.building_name,
        street_address: first.street_address,
        city: first.city,
        state: first.state,
        zip_code: first.zip_code
      )
      next unless existing
      existing_units = existing.units.pluck(:unit_number)
      staged_units = rows.select(&:unit_number_present?).map { |r| r.unit_number.to_s.strip }.uniq
      conflicting_units = existing_units & staged_units
      conflicts << {
        key: key.join("\t"),
        rows: rows,
        existing_property: existing,
        existing_units: existing_units,
        staged_units: staged_units,
        conflicting_units: conflicting_units,
        conflicting_rows: rows.select { |r| r.unit_number_present? && conflicting_units.include?(r.unit_number.to_s.strip) }
      }
    end
    conflicts
  end

  def build_summary
    groups = @import_session.staged_rows.reload.order(:row_number).group_by(&:property_key)
    new_properties = 0
    existing_properties = 0
    new_units_total = 0
    existing_new_units = 0
    groups.each do |_key, rows|
      next if rows.empty?
      next if rows.any?(&:skip_property?)
      first = rows.first
      existing = Property.find_by_composite(
        building_name: first.building_name,
        street_address: first.street_address,
        city: first.city,
        state: first.state,
        zip_code: first.zip_code
      )
      units_to_add = rows.count { |r| r.unit_number_present? && !r.skip_unit }
      if existing
        existing_properties += 1
        existing_new_units += units_to_add
      else
        new_properties += 1
        new_units_total += units_to_add
      end
    end
    {
      new_properties: new_properties,
      existing_properties: existing_properties,
      new_units_total: new_units_total,
      existing_new_units: existing_new_units
    }
  end
end
