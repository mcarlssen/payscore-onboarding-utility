# frozen_string_literal: true

module Imports
  class StagedRowsController < ApplicationController
    before_action :set_import_and_row

    def destroy
      @staged_row.destroy!
      redirect_to preview_import_path(@import_session), notice: "Row deleted."
    end

    private

    def set_import_and_row
      @import_session = ImportSession.find(params[:import_id])
      @staged_row = @import_session.staged_rows.find(params[:staged_row_id])
    end
  end
end
