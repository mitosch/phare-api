# frozen_string_literal: true

require "swagger_helper"

RSpec.describe Api::V1::Public::PagesController do
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

        let!(:pages) { FactoryBot.create_list(:page, 5) }
        run_test!
      end
    end
  end

  path "/api/v1/pub/pages/{id}" do
    get "get page" do
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      response "200", "page found" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            url: { type: :string },
            audit_frequency: { type: :string, enum: ["hourly", "daily"] },
            status: { type: :string, enum: ["active", "inactive", "archived"] }
        }

        let(:id) { FactoryBot.create(:page).id }
        run_test!
      end

      response "404", "page not found" do
        let(:id) { "invalid" }
        run_test!
      end
    end
  end
end
