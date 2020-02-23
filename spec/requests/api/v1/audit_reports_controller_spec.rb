# frozen_string_literal: true

require "swagger_helper"

RSpec.describe Api::V1::Public::AuditReportsController do
  path "/api/v1/pub/pages/{page_id}/audit_reports" do
    get "list audit reports of page" do
      produces "application/json"
      parameter name: :page_id, in: :path, type: :string

      parameter name: :with,
                in: :query,
                type: :array,
                required: false,
                collectionFormat: :csv,
                description: "summary: returns numeric and display values of the key performance metrics, lighthouse: add lighthouse json to the response",
                items: {
                  type: :string,
                  enum: ["summary", "lighthouse"]
                }

      parameter name: :limit,
                in: :query,
                type: :integer,
                required: false,
                description: "limit number of returned audit reports"

      response "200", "audit reports found" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              audit_type: { type: :string, enum: ["psi", "lighthouse"] },
              summary: {
                type: :object,
                properties: {
                  fetchTime: { type: :string, format: "date-time" },
                  "max-potential-fid": {
                    type: :object,
                    properties: {
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "first-meaningful-paint": {
                    type: :object,
                    properties: {
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "first-cpu-idle": {
                    type: :object,
                    properties: {
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "first-contentful-paint": {
                    type: :object,
                    properties: {
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "speed-index": {
                    type: :object,
                    properties: {
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "interactive": {
                    type: :object,
                    properties: {
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                }
              },
              lighthouseResult: {
                type: :object,
                properties: {}
              }
            }
          }

        let(:page_id) { FactoryBot.create(:page).id }
        run_test!
      end
    end
  end

  # TODO: write FactoryBot first with audit_reports and a full lightspeed response
  path "/api/v1/pub/pages/{page_id}/audit_reports/{id}" do
    get "get audit report of page" do
    end
  end
end
