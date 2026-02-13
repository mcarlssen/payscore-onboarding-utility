# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :set_import_session, only: %i[show preview preview_update conflicts conflicts_resolve summary confirm rollback discard]
  before_action :disable_cache, only: %i[preview conflicts summary]

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
    errors_by_row = {}
    (params[:staged_rows] || {}).each do |id, attrs|
      row = @import_session.staged_rows.find_by(id: id)
      next unless row
      permitted = attrs.permit(:building_name, :street_address, :unit_number, :city, :state, :zip_code)
      updates = permitted.to_h.transform_values { |v| v.to_s.strip }
      updates["unit_number"] = updates["unit_number"].presence
      row.update_columns(updates)
      row.reload
      errs = []
      errs << "Building Name required" if row.building_name.to_s.strip.upcase.blank?
      errs << "Street Address required" if row.street_address.to_s.strip.upcase.blank?
      errs << "City required" if row.city.to_s.strip.upcase.blank?
      errs << "State required" if row.state.to_s.strip.upcase.blank?
      errs << "Zip Code required" if row.zip_code.to_s.strip.upcase.blank?
      validation_errors = errs.presence&.to_json
      row.update_column(:validation_errors, validation_errors)
      errors_by_row[row.id] = errs if errs.present?
    end
    respond_to do |format|
      format.html { redirect_to preview_import_path(@import_session), notice: errors_by_row.present? ? "Some rows had errors." : "Saved." }
      format.json { render json: { errors: errors_by_row } }
    end
  end

  def conflicts
    clear_orphaned_skip_flags
    @conflicts = conflict_groups
    # Default all conflicting rows to skip on first visit (when no "keep" has been chosen yet)
    conflicting_rows = @conflicts.flat_map { |c| c[:conflicting_rows] }.uniq
    if conflicting_rows.any? && conflicting_rows.all? { |r| r.skip_unit == false }
      conflicting_ids = conflicting_rows.map(&:id)
      @import_session.staged_rows.where(id: conflicting_ids).update_all(skip_unit: true)
      @conflicts = conflict_groups # reload with updated skip_unit
    end
  end

  def conflicts_resolve
    skip_keys = params[:skip_property] || []
    all_keys = params[:conflict_keys] || []

    # Step 1: Set skip_property based on checkbox. For skipped properties, also set skip_unit=true.
    all_keys.each do |key|
      row_ids = @import_session.staged_rows.select { |r| r.property_key.join("\t") == key }.map(&:id)
      next if row_ids.empty?
      if skip_keys.include?(key)
        @import_session.staged_rows.where(id: row_ids).update_all(skip_unit: true, skip_property: true)
      else
        # Un-skip: set skip_property=false, skip_unit=false for all (default keep all). Step 2 will mark conflicting rows as skip, step 3 will mark kept.
        @import_session.staged_rows.where(id: row_ids).update_all(skip_property: false, skip_unit: false)
      end
    end

    # Step 2: For un-skipped properties, apply unit-level choices: default conflicting rows to skip, then set kept via keep_unit
    unskip_keys = all_keys - skip_keys
    unskip_row_ids = unskip_keys.flat_map do |key|
      @import_session.staged_rows.select { |r| r.property_key.join("\t") == key }.map(&:id)
    end
    unskip_id_set = unskip_row_ids.map(&:to_s).to_set

    (params[:conflicting_row_ids] || []).each do |row_id|
      next unless unskip_id_set.include?(row_id.to_s)
      @import_session.staged_rows.where(id: row_id).update_all(skip_unit: true)
    end
    (params[:keep_unit] || {}).each do |_unit_key, row_id|
      next if row_id.blank?
      next unless unskip_id_set.include?(row_id.to_s)
      @import_session.staged_rows.where(id: row_id).update_all(skip_unit: false)
    end
    redirect_to summary_import_path(@import_session)
  end

  def summary
    clear_orphaned_skip_flags
    @summary = build_summary
    @rows_to_import = rows_to_import
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

  def rollback
    result = ImportRollbackService.new(@import_session).call
    if result[:ok]
      redirect_to root_path, notice: "Import rolled back."
    else
      redirect_to root_path, alert: result[:error]
    end
  end

  private

  def disable_cache
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end

  # Rows that were edited to a new address are now in a different property_key group.
  # They may still have skip_property/skip_unit from when they were in a skipped group.
  # Clear those flags for rows that are the sole row in their group (they've "moved" to a new property).
  def clear_orphaned_skip_flags
    groups = @import_session.staged_rows.reload.order(:row_number).group_by(&:property_key)
    groups.each do |_key, rows|
      next unless rows.size == 1
      row = rows.first
      next unless row.skip_property? || row.skip_unit?
      row.update_columns(skip_property: false, skip_unit: false)
    end
  end

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
      existing_units = existing ? existing.units.pluck(:unit_number) : []
      staged_units = rows.select(&:unit_number_present?).map { |r| r.unit_number.to_s.strip }.uniq

      # DB conflict: units that already exist in the database
      db_conflicting_units = existing_units & staged_units

      # Within-import duplicates: unit numbers that appear more than once in this group
      unit_to_rows = rows.select(&:unit_number_present?).group_by { |r| r.unit_number.to_s.strip }
      within_import_duplicate_units = unit_to_rows.select { |_u, rrows| rrows.size > 1 }.keys

      # Show conflict if: (1) property exists in DB, or (2) within-import duplicates
      # Per BUILD: "look up an existing Property by that composite. If found → conflict."
      # Property-only imports (no units) appear here ONLY when existing.present? — not because
      # they lack units, but because the property already exists in the database.
      next unless existing.present? || within_import_duplicate_units.any?

      conflicting_units = (db_conflicting_units | within_import_duplicate_units).uniq
      conflicting_rows = rows.select { |r| r.unit_number_present? && conflicting_units.include?(r.unit_number.to_s.strip) }
      rows_by_unit = conflicting_rows.group_by { |r| r.unit_number.to_s.strip }

      conflicts << {
        key: key.join("\t"),
        rows: rows,
        existing_property: existing,
        existing_units: existing_units,
        staged_units: staged_units,
        conflicting_units: conflicting_units,
        conflicting_rows: conflicting_rows,
        rows_by_unit: rows_by_unit,
        db_conflicting_units: db_conflicting_units,
        within_import_duplicate_units: within_import_duplicate_units
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

  # Rows that will be inserted (subset of staged_rows): excludes skip_property groups,
  # and within each group excludes rows with skip_unit. Matches ImportCommitService logic.
  def rows_to_import
    groups = @import_session.staged_rows.reload.order(:row_number).group_by(&:property_key)
    rows = []
    groups.each do |_key, group_rows|
      next if group_rows.any?(&:skip_property?)
      group_rows.each do |row|
        next if row.unit_number_present? && row.skip_unit
        rows << row
      end
    end
    rows.sort_by(&:row_number)
  end
end
