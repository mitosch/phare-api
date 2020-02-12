# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for getting statistics of a page
      class StatisticsController < PublicController
        # GET /pub/pages/:page_id/statistics
        #
        # curl -X GET -H "Content-Type: application/json" \
        #   http://localhost:3000/api/v1/pub/pages/1/statistics
        #
        # first-contentful-paint  fcp
        # first-meaningful-paint  fmp
        # speed-index             si
        # interactive             ia
        # first-cpu-idle          fci
        # max-potential-fid       mpf
        def show
          page = Page.find(params[:page_id])

          payload = []
          page.audit_reports.each do |report|
            next unless report.body["lighthouseResult"]

            lh = report.body["lighthouseResult"]

            payload << {
              fetchTime: lh.dig("fetchTime"),
              mpf: lh.dig("audits", "max-potential-fid", "numericValue"),
              fmp: lh.dig("audits", "first-meaningful-paint", "numericValue"),
              fci: lh.dig("audits", "first-cpu-idle", "numericValue"),
              fcp: lh.dig("audits", "first-contentful-paint", "numericValue"),
              si: lh.dig("audits", "speed-index", "numericValue"),
              ia: lh.dig("audits", "interactive", "numericValue")
            }
          end

          # TODO: sort payload by fetchTime

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end
      end
    end
  end
end
