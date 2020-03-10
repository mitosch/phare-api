# frozen_string_literal: true

# Join model for labels on pages
class LabelPage < ApplicationRecord
  belongs_to :label
  belongs_to :page
end
