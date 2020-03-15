# frozen_string_literal: true

require "swagger_helper"

# TODO: check multiple response tests
RSpec.describe Api::V1::Public::AuditReportsController do
  path "/api/v1/pub/pages/{page_id}/audit_reports" do
    get "list audit reports of page" do
      produces "application/json"
      parameter name: :page_id, in: :path, type: :string

      parameter name: "fields[auditReports]",
                in: :query,
                type: :array,
                required: false,
                collectionFormat: :csv,
                description: "sparese fields. lighthouseResult: add lighthouse json to the response",
                items: {
                  type: :string,
                  enum: ["lighthouseResult"]
                }
      
      parameter name: "page[limit]",
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
              auditType: { type: :string, enum: ["psi", "lighthouse"] },
              summary: {
                type: :object,
                properties: {
                  fetchTime: { type: :string, format: "date-time" },
                  "max-potential-fid": {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      score: { type: :number },
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "first-meaningful-paint": {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      score: { type: :number },
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "first-cpu-idle": {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      score: { type: :number },
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "first-contentful-paint": {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      score: { type: :number },
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "speed-index": {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      score: { type: :number },
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                  "interactive": {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      score: { type: :number },
                      numericValue: { type: :number },
                      displayValue: { type: :string }
                    }
                  },
                }
              },
              lighthouseResult: {
                type: :object,
                properties: {},
                "x-nullable": true
              }
            },
            required: ["id", "auditType", "summary"]
          }

        let(:page_id) { FactoryBot.create(:page_with_audit_report).id }
        run_test!
      end
    end
  end

  path "/api/v1/pub/pages/{page_id}/audit_reports/{audit_report_id}" do
    get "get audit report of page" do
      produces "application/json"
      parameter name: :page_id, in: :path, type: :string
      parameter name: :audit_report_id, in: :path, type: :string

      response "200", "audit report found" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            auditType: { type: :string, enum: ["psi", "lighthouse"] },
            summary: {
              type: :object,
              properties: {
                fetchTime: { type: :string, format: "date-time" },
                "max-potential-fid": {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    score: { type: :number },
                    numericValue: { type: :number },
                    displayValue: { type: :string }
                  }
                },
                "first-meaningful-paint": {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    score: { type: :number },
                    numericValue: { type: :number },
                    displayValue: { type: :string }
                  }
                },
                "first-cpu-idle": {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    score: { type: :number },
                    numericValue: { type: :number },
                    displayValue: { type: :string }
                  }
                },
                "first-contentful-paint": {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    score: { type: :number },
                    numericValue: { type: :number },
                    displayValue: { type: :string }
                  }
                },
                "speed-index": {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    score: { type: :number },
                    numericValue: { type: :number },
                    displayValue: { type: :string }
                  }
                },
                "interactive": {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    score: { type: :number },
                    numericValue: { type: :number },
                    displayValue: { type: :string }
                  }
                },
              }
            },
            lighthouseResult: {
              type: :object,
              properties: {},
              "x-nullable": true
            }
          },
          required: ["id", "auditType", "summary"]

        let(:page) { create(:page_with_audit_report) }
        let(:page_id) { page.id }
        let(:audit_report_id) { page.audit_reports.first.id }
        run_test!
      end
    end
  end
end
