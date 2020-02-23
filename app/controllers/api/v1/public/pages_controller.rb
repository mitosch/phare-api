# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for pages beeing monitored
      class PagesController < PublicController
        # GET /pub/pages
        #
        # Returns all pages
        def index
          pages = Page.all

          render json: pages
        end

        # GET /pub/pages/:page_id
        #
        # Returns a specific page
        def show
          page = Page.find(params[:id])

          render json: page
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        # PUT /pub/pages
        #
        # Adds an URL to the queue or requeues it, if it already exists.
        def create_or_update
          uri = parse_url(page_params[:url])

          page = Page.find_or_create_by(url: uri.to_s)
          # OPTIMIZE: check if possible above with block...
          if page_params[:audit_frequency]
            page.audit_frequency = page_params[:audit_frequency]
            page.save
          end
          PageAuditJob.perform_later(page)

          render json: page
        rescue URI::InvalidURIError
          render json: { error: "invalid url" }, status: :bad_request
        end

        private
          def page_params
            params.permit(%i[url audit_frequency])
          end

          # TODO: DRY (audit_reports_controller) -> move to Page model valid.
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
