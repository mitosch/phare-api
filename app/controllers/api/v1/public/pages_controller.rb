# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for pages beeing monitored
      class PagesController < PublicController
        SUMMARY_METRICS = {
          max_potential_fid: "max-potential-fid",
          first_meaningful_paint: "first-meaningful-paint",
          first_cpu_idle: "first-cpu-idle",
          first_contentful_paint: "first-contentful-paint",
          speed_index: "speed-index",
          interactive: "interactive"
        }.freeze

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

        # GET /pub/pages/:page_id/statistics
        #
        # Returns a specific page
        def statistics
          page = Page.find(params[:page_id])

          select_fields = prepare_selected_fields

          payload = page
                    .audit_reports
                    .select(select_fields)
                    .group("day")
                    .order("day")
          render json: payload.to_json(except: :id)
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

          def prepare_selected_fields
            select_fields = [
              "TO_DATE(summary" \
              "->>'fetchTime', 'YYYY-MM-DD') AS day"
            ]

            SUMMARY_METRICS.each do |key, metric|
              select_fields.push("AVG(CAST(summary" \
                                 "->'#{metric}'->>'numericValue' " \
                                 "AS FLOAT)) AS #{key}")
            end

            select_fields
          end
      end
    end
  end
end
