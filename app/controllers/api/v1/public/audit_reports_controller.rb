# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for audit reports
      #
      # Currently in use for manually adding audit reports to pages
      #
      # rubocop:disable Metrics/ClassLength
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
          limit = params[:limit] || nil

          page = Page.find(params[:page_id])

          select_fields = prepare_selected_fields

          payload = []
          page
            .audit_reports
            .select(select_fields)
            .order(created_at: :desc)
            .limit(limit)
            .each do |report|
            report_data = {
              id: report.id,
              audit_type: report.audit_type
            }

            if with_params("lighthouse")
              report_data[:lighthouseResult] = report
                                               .body["lighthouseResult"]
            end

            if with_params("summary")
              report_data[:summary] = extract_summary(report)
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

          # Returns if the GET parameter "with" includes the string
          def with_params(with)
            return false unless params[:with]

            params[:with].split(",").include?(with)
          end

          def prepare_selected_fields
            select_fields = %i[id audit_type]

            select_fields.push(:body) if with_params("lighthouse")

            if with_params("summary")
              select_fields.push("body->'lighthouseResult'->" \
                                 "'fetchTime' as fetch_time")
              SUMMARY_METRICS.each do |key, metric|
                delete_op = EXCLUDE_ATTRIBUTES.map { |a| "#- '{#{a}}'" }
                                              .join(" ")

                select_fields
                  .push("body->'lighthouseResult'->" \
                        "'audits'->'#{metric}' #{delete_op} as #{key}")
              end
            end

            select_fields
          end

          # TODO: DRY (pages_controller) -> move to Page model validation
          def parse_url(url)
            unless url.start_with?("http://", "https://")
              raise URI::InvalidURIError, "Invalid URL", url
            end

            URI.parse(url)
          end

          def extract_summary(report)
            summary = {
              fetchTime: report.fetch_time
            }

            SUMMARY_METRICS.each do |key, metric|
              summary[metric] = report[key]
            end

            summary
          end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
