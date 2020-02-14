# frozen_string_literal: true

# A Page with an URL which will be fetched continuously
class Page < ApplicationRecord
  enum status: {
    active: 0,
    inactive: 1,
    archived: 2
  }

  enum audit_frequency: {
    hourly: 0,
    daily: 1
  }

  has_many :audit_reports, dependent: :destroy
end
