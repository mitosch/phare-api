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
          uri = parse_url(page_params[:url])

          # TODO: after ActiveJob; force a new job, currently does nothing
          page = Page.find_or_create_by(url: uri.to_s)
          page.save

          # TODO: setup ActiveJob and run there
          PageAuditor.call(page)

          render json: { done: true }
        rescue URI::InvalidURIError
          render json: { error: "invalid url" }, status: :bad_request
        end

        private
          def page_params
            params.permit([:url])
          end

          def parse_url(url)
            unless url.start_with?("http://", "https://")
              raise URI::InvalidURIError, "Invalid URL", url
            end

            URI.parse(url)
          end
      end
    end
  end
end
