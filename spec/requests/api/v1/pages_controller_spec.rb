# frozen_string_literal: true

require "rails_helper"
require "swagger_helper"

# TODO: change version to swagger 2.0 (or adapt to OpenAPI 3.0.1)

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
              audit_frequency: { type: :string },
              status: { type: :string }
            }
          }

        run_test!
      end
    end
  end
end
