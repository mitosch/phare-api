# frozen_string_literal: true

require "swagger_helper"

RSpec.describe Api::V1::Public::PagesController do
  path "/api/v1/pub/pages" do
    put "add or requeue page" do
      consumes "application/json"
      produces "application/json"

      parameter name: :page, in: :body, schema: {
        type: :object,
        properties: {
          url: { type: :string },
          audit_frequency: { type: :string }
        },
        required: ["url"]
      }

      response "200", "page created and requeued" do
        let(:page) { { url: "https://www.google.com", audit_frequency: "hourly" } }
        run_test!
      end
    end

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
