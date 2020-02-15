# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

RSpec.describe Api::V1::Public::PagesController do
  before(:all) do
    FactoryBot.create_list(:page, 5)
  end

  path "/api/v1/pub/pages" do
    get "list pages" do
      produces "application/json"

      response "200", "pages found" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              url: { type: :string },
              audit_frequency: { type: :string, enum: ["hourly", "daily"] },
              status: { type: :string, enum: ["active", "inactive", "archived"] }
            }
          }

        run_test!
      end
    end
  end
end
