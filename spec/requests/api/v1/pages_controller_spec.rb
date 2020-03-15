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
          audit_frequency: { type: :string, enum: ["hourly", "daily"] }
        },
        required: ["url"]
      }

      response "200", "page created and requeued" do
        let(:page) { { url: "https://www.google.com", audit_frequency: "hourly" } }
        run_test!
      end

      response "400", "invalid url" do
        let(:page) { { url: "htp://www.google.com", audit_frequency: "hourly" } }
        run_test!
      end
    end

    get "list pages" do
      produces "application/json"

      parameter name: :include,
                in: :query,
                type: :array,
                required: false,
                collectionFormat: :csv,
                description: "include associations of pages, e.g. label",
                items: {
                  type: :string,
                  enum: ["label"]
                }

      parameter name: "filter[label]",
                in: :query,
                type: :array,
                required: false,
                collectionFormat: :csv,
                description: "filter for pages with specific label IDs",
                items: {
                  type: :number
                }


      response "200", "pages found" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              url: { type: :string },
              auditFrequency: { type: :string, enum: ["hourly", "daily"] },
              status: { type: :string, enum: ["active", "inactive", "archived"] },
              lastAuditedAt: { type: :string, format: "date-time", "x-nullable": true },
              label: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  color: { type: :string }
                }
              }
            },
            required: ["id", "url", "auditFrequency", "status", "lastAuditedAt"]
          }

        # NOTE: workaround for bug in rswag. https://github.com/rswag/rswag/pull/197
        context "include or filter not set" do
          let(:include) { [] }
          let!(:pages) { FactoryBot.create_list(:page, 5) }

          run_test!
        end

        # TODO: check for label prop in response
        context "include label given" do
          let(:include) { ["label"] }
          let!(:pages) { FactoryBot.create_list(:page, 5) }

          run_test!
        end

        # TODO: check for specific pages with label id only
        context "include label and filter label given" do
          let(:include) { ["label"] }
          # TODO: implement create pages with labels and use real id
          let(:"filter[label]") { [1] }
          let!(:pages) { FactoryBot.create_list(:page, 5) }

          run_test!
        end
      end
    end
  end

  path "/api/v1/pub/pages/{id}" do
    get "get page" do
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      parameter name: :include,
                in: :query,
                type: :array,
                required: false,
                collectionFormat: :csv,
                description: "include associations of pages, e.g. label",
                items: {
                  type: :string,
                  enum: ["label"]
                }

      response "200", "page found" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            url: { type: :string },
            auditFrequency: { type: :string, enum: ["hourly", "daily"] },
            status: { type: :string, enum: ["active", "inactive", "archived"] },
            lastAuditedAt: { type: :string, format: "date-time", "x-nullable": true },
            label: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                color: { type: :string }
              }
            }
        },
        required: ["id", "url", "auditFrequency", "status", "lastAuditedAt"]

        let(:include) { [] }
        let(:id) { FactoryBot.create(:page).id }
        run_test!
      end

      response "404", "page not found" do
        let(:include) { [] }
        let(:id) { "invalid" }
        run_test!
      end
    end
  end

  path "/api/v1/pub/pages/{id}/statistics" do
    get "get statistics of page" do
      # deprecated true
      produces "application/json"
      parameter name: :id, in: :path, type: :string

      response "200", "page found" do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              day: { type: :string },
              max_potential_fid: { type: :number },
              first_meaningful_paint: { type: :number },
              first_cpu_idle: { type: :number },
              first_contentful_paint: { type: :number },
              speed_index: { type: :number },
              interactive: { type: :number }
            }
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

  path "/api/v1/pub/pages/{id}/label" do
    put "assign/remove label to/from page" do
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string

      parameter name: :label, in: :body, schema: {
        type: :object,
        properties: {
          label: {
            type: :object,
            properties: {
              id: { type: :integer }
            }
          }
        },
        required: ["label"]
      }

      response "200", "label assigned/removed" do
        context "label id given to assign label" do
          let(:page) { create(:page) }
          let(:id) { page.id }
          let(:label_id) { create(:label).id }
          let(:label) { { label: { id: label_id } } }

          run_test!
        end

        # TODO: create page with label, then remove
        context "minus-1 given to remove label" do
          let(:page) { create(:page) }
          let(:id) { page.id }
          let(:label_id) { create(:label).id }
          let(:label) { { label: { id: -1 } } }

          run_test!
        end
      end

      response "400", "invalid payload" do
        let(:page) { create(:page) }
        let(:id) { page.id }
        let(:label_id) { create(:label).id }
        # labels instead of label
        let(:label) { { labels: { id: label_id } } }

        run_test!
      end

      response "404", "page or label not found" do
        context "invalid page id given" do
          let(:page) { create(:page) }
          let(:id) { "invalid" }
          let(:label_id) { create(:label).id }
          let(:label) { { label: { id: label_id } } }

          run_test!
        end

        context "invalid label id given" do
          let(:page) { create(:page) }
          let(:id) { page.id }
          let(:label_id) { create(:label).id }
          let(:label) { { label: { id: label_id + 1 } } }

          run_test!
        end
      end
    end
  end
end
