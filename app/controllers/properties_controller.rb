# frozen_string_literal: true

class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:units).order(:building_name)
  end

  def show
    @property = Property.find(params[:id])
    @units = @property.units.order(:unit_number)
  end
end
