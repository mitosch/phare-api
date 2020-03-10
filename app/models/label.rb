# frozen_string_literal: true

# A Label which can be assigned to pages
class Label < ApplicationRecord
  has_many :label_pages, dependent: :destroy
  has_many :pages, through: :label_pages
end
