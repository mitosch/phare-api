# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for audit reports
      #
      # Currently in use for manually adding audit reports to pages
      class AuditReportsController < PublicController
        SUMMARY_METRICS = %w[
          max-potential-fid
          first-meaningful-paint
          first-cpu-idle
          first-contentful-paint
          speed-index
          interactive
        ].freeze

        # GET /pub/pages/:page_id/audit_reports
        def index
          page = Page.find(params[:page_id])

          payload = []
          page.audit_reports.each do |report|
            report_data = {
              id: report.id,
              audit_type: report.audit_type
            }

            if params[:with] && params[:with] == "summary"
              report_data[:summary] = extract_summary(
                report.body["lighthouseResult"]
              )
            end

            payload << report_data
          end

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        # GET /pub/pages/:page_id/audit_reports/:id
        def show
          page = Page.find(params[:page_id])

          render json: page.audit_reports.find(params[:id])
        rescue ActiveRecord::RecordNotFound # Page or AuditReport
          render json: { error: "record not found" }, status: :not_found
        end

        # POST /pub/audit_reports
        #
        # expected payload:
        # {
        #   "url": "https://www.example.com",
        #   "report": {}
        # }
        #
        # report type (psi, lighthouse) will be identified automatically
        #
        # curl -X POST -H "Content-Type: application/json" \
        #   -d '{"url":"https://www.example.com", "report": {} }' \
        #   http://localhost:3000/api/v1/pub/audit_reports
        def create
          report = params.delete(:report)
          uri = parse_url(audit_report_params[:url])

          page = Page.find_by(url: uri.to_s)
          unless page
            render json: { error: "page not found" }, status: :bad_request
            return
          end

          # TODO: guess audit_type by parsing report, raise exc for unknown
          audit_report = page.audit_reports.create(
            audit_type: "psi",
            body: report
          )

          render json: {
            id: audit_report.id,
            audit_type: audit_report.audit_type
          }, status: :created
        rescue URI::InvalidURIError
          render json: { error: "invalid url" }, status: :bad_request
        end

        private
          def audit_report_params
            params.permit([:url])
          end

          # TODO: DRY (pages_controller) -> move to Page model validation
          def parse_url(url)
            unless url.start_with?("http://", "https://")
              raise URI::InvalidURIError, "Invalid URL", url
            end

            URI.parse(url)
          end

          def extract_summary(lighthouse_report)
            summary = {
              fetchTime: lighthouse_report.dig("fetchTime")
            }

            SUMMARY_METRICS.each do |metric|
              summary[metric] = lighthouse_report.dig(
                "audits",
                metric
              ).slice("numericValue", "displayValue")
            end

            summary
          end
      end
    end
  end
end
