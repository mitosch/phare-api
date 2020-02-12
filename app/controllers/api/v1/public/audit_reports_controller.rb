# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for audit reports
      #
      # Currently in use for manually adding audit reports to pages
      class AuditReportsController < PublicController
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
        #   -d '{"url":"https://www.swisscom.ch", "report": {} }' \
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

          # TODO: DRY (pages_controller)
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
