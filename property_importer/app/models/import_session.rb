# frozen_string_literal: true

class ImportSession < ApplicationRecord
  has_many :staged_rows, dependent: :destroy

  STATUSES = %w[draft committed failed].freeze
  validates :status, inclusion: { in: STATUSES }

  def committed?
    status == "committed"
  end

  def draft?
    status == "draft"
  end
end
