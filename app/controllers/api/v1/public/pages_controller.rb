# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for pages beeing monitored
      class PagesController < PublicController
        # PUT /pub/pages
        #
        # expected payload:
        # {
        #   "url": "https://www.example.com"
        # }
        #
        # Adds an URL to the queue or requeues it, if it already exists.
        #
        # Upcoming features:
        # * define request time (hourly, daily, etc.)
        #
        # Example:
        # curl -X PUT -H "Content-Type: application/json" \
        #   -d '{"url":"https://www.example.com"}' \
        #   http://localhost:3000/api/v1/pub/pages
        def create_or_update
          render json: { done: true }
        end
      end
    end
  end
end
