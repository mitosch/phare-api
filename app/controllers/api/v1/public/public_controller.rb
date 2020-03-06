# frozen_string_literal: true

module Api
  module V1
    module Public
      # API functionalities for all public endpoints.
      class PublicController < Api::V1::ApiController
        before_action :client_key_authorize!

        protected
          def client_key_authorize!
            if ENV["CLIENT_KEY"].present? && !(
               ENV["CLIENT_KEY"] == auth_credentials ||
               ENV["CLIENT_KEY"] == params[:key])
              render json: {
                error: "client key missing"
              }, status: :unauthorized
            end
          end

        private
          def auth_credentials
            return nil unless request.headers["Authorization"]

            type, credentials = request.headers["Authorization"].split(" ")

            return nil unless type == "ApiKey"

            credentials
          end
      end
    end
  end
end
