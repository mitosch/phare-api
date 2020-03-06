# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for audit reports
      #
      # FIXME: Unpermitted params in index
      class AuditReportsController < PublicController
        SUMMARY_METRICS = {
          max_potential_fid: "max-potential-fid",
          first_meaningful_paint: "first-meaningful-paint",
          first_cpu_idle: "first-cpu-idle",
          first_contentful_paint: "first-contentful-paint",
          speed_index: "speed-index",
          interactive: "interactive"
        }.freeze

        EXCLUDE_ATTRIBUTES = %w[
          description
          title
          scoreDisplayMode
        ].freeze

        # GET /pub/pages/:page_id/audit_reports
        def index
          limit = params[:page] && params[:page][:limit] || nil

          page = Page.find(params[:page_id])

          fields = sparse_fields(auditReport: %w[id])

          if fields[:auditReport].include?("lighthouseResult")
            fields[:auditReport] << "body"
          end

          selected_fields = select_fields(fields[:auditReport])

          audit_reports = page
                          .audit_reports
                          .select(selected_fields)
                          .order(Arel.sql("summary->'fetchTime' DESC"))
                          .limit(limit)

          render json: AuditReportSerializer.new(
            audit_reports,
            {}.merge(fields: fields)
          )
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

          # Returns if the GET parameter "with" includes the string
          def with_params(with)
            return false unless params[:with]

            params[:with].split(",").include?(with)
          end

          # Returns a hash from params for generating a sparse fieldset
          def sparse_fields(defaults = {})
            result = params.permit(fields: {})[:fields]

            fieldset = result.to_h.map do |k, v|
              v = v.split(",") if v.is_a?(String)
              # merge array of fields, if defaults given
              # NOTE: did not work, when result was empty
              # v |= defaults[k.to_sym] if defaults[k.to_sym]
              [k, v]
            end.to_h.with_indifferent_access

            # merge array of fields, if defaults given
            defaults.each do |k, v|
              fieldset[k] = (fieldset[k] || []) | v
            end

            fieldset
          end

          # Returns an array with existing attributes
          def select_fields(fields)
            # fields.map!(&:underscore)
            fields.map(&:underscore).select do |field|
              AuditReport.column_names.include?(field)
            end
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
