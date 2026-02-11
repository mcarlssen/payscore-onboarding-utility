# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder nil
  protect_from_forgery with: :exception
end
