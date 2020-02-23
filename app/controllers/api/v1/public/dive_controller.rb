# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for deep dives
      #
      # NOTE: this is a proof-of-concept and will probably be re-written
      class DiveController < PublicController
        # GET /pub/pages/:page_id/dive
        #
        # Returns items of a given audit.
        #
        # params:
        #
        # audit:   audit, e.g.: "render-blocking-resources"
        #
        # tbd:
        # field:  field to query, e.g.: "url"
        # q:      string to look for
        def show
          # NOTE: currently not in use, only audits can be queried
          # type      = params[:type]     || "opportunity"
          # NOTE: filter, which could be implemented later
          # field     = params[:field]    || "url"
          # query     = params[:q]
          audit = params[:audit] || "render-blocking-resources"

          page = Page.find(params[:page_id])

          payload = []
          page.audit_reports.each do |report|
            lh = report.body["lighthouseResult"]

            payload << {
              auditReportId: report.id,
              fetchTime: lh["fetchTime"],
              items: lh["audits"][audit]["details"]["items"]
            }
          end

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end
      end
    end
  end
end
