# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for audit reports
      #
      # FIXME: Unpermitted params in index
      class AuditReportsController < PublicController
        # GET /pub/pages/:page_id/audit_reports
        # TODO: reduce Cyclomatic complexity
        # rubocop:disable Metrics/CyclomaticComplexity
        def index
          limit = params[:page] && params[:page][:limit] || nil

          needs_body = fieldsets["auditReports"]
            &.include?("lighthouseResult") || false

          page = Page.find(params[:page_id])

          audit_reports = page
                          .audit_reports
                          .limit(limit)

          audit_reports = audit_reports.without_body unless needs_body

          render json: AuditReportSerializer.new(
            audit_reports,
            params: { with_body: needs_body ? true : false }
          ).serialized_json
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        # GET /pub/pages/:page_id/audit_reports/:id
        def show
          page = Page.find(params[:page_id])

          audit_report = page.audit_reports.find(params[:id])

          render json: AuditReportSerializer.new(
            audit_report,
            params: { with_body: true }
          ).serialized_json
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

          # Returns if the GET parameter "with" includes the string
          def with_params(with)
            return false unless params[:with]

            params[:with].split(",").include?(with)
          end

          def fieldsets
            result = params.permit(fields: {})[:fields]

            result.to_h.map do |k, v|
              v = v.split(",") if v.is_a?(String)
              # merge array of fields, if defaults given
              # NOTE: did not work, when result was empty
              # v |= defaults[k.to_sym] if defaults[k.to_sym]
              [k, v]
            end.to_h
          end

          # TODO: DRY (pages_controller) -> move to Page model validation
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
