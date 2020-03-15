# frozen_string_literal: true

require "swagger_helper"

# GET    /api/v1/pub/labels(.:format)      api/v1/public/labels#index
# POST   /api/v1/pub/labels(.:format)      api/v1/public/labels#create
# GET    /api/v1/pub/labels/:id(.:format)  api/v1/public/labels#show
# PATCH  /api/v1/pub/labels/:id(.:format)  api/v1/public/labels#update
# PUT    /api/v1/pub/labels/:id(.:format)  api/v1/public/labels#update
# DELETE /api/v1/pub/labels/:id(.:format)  api/v1/public/labels#destroy
RSpec.describe Api::V1::Public::LabelsController do
  path "/api/v1/pub/labels" do
    get "list labels" do
      produces "application/json"

      response "200", "labels found" do
        schema type: :array,
          items: {
          type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            color: { type: :string },
          },
          required: ["id", "name", "color"]
        }

        let!(:labels) { create_list(:label, 5) }

        run_test!
      end
    end

    post "create label" do
      consumes "application/json"
      produces "application/json"

      parameter name: :label, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          color: { type: :string }
        },
        required: ["name"]
      }

      response "201", "label created" do
        let(:label) { { name: "New Label", color: "pink" } }

        run_test!
      end
    end
  end

  path "/api/v1/pub/labels/{id}" do
    get "get label" do
      produces "application/json"

      parameter name: :id, in: :path, type: :string

      response "200", "label found" do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            color: { type: :string },
          },
          required: ["id", "name", "color"]

        let(:id) { create(:label).id }
        
        run_test!
      end

      response "404", "label not found" do
        let(:id) { "invalid" }
        
        run_test!
      end
    end

    put "update label" do
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string

      parameter name: :label, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          color: { type: :string }
        }
      }

      response "200", "label updated" do
        let(:id) { create(:label).id }
        let(:label) { { color: "pink" } }

        run_test!
      end

      response "404", "label not found" do
        let(:id) { "invalid" }
        let(:label) { { color: "pink" } }
        
        run_test!
      end
    end

    # TODO: not yet implemented
    #delete "delete label" do
    #end
  end
end
