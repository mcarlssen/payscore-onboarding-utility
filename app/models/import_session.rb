# frozen_string_literal: true

class ImportSession < ApplicationRecord
  has_many :staged_rows, dependent: :destroy

  STATUSES = %w[draft committed failed rolled_back].freeze
  validates :status, inclusion: { in: STATUSES }

  def committed?
    status == "committed"
  end

  def draft?
    status == "draft"
  end

  def rolled_back?
    status == "rolled_back"
  end
end
