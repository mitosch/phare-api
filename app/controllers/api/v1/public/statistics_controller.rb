# frozen_string_literal: true

require "standard_deviation"

module Api
  module V1
    module Public
      # API endpoint for getting statistics of a page
      class StatisticsController < PublicController
        METRICS = %i[mpf fmp fci fcp si ia].freeze

        # GET /pub/pages/:page_id/statistics
        #
        # params:
        # merge   enum  daily: merge values and return mean
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

            fetch_time = lh.dig("fetchTime")
            payload << {
              auditReportId: report.id,
              fetchTime: fetch_time,
              day: Date.parse(fetch_time),
              mpf: lh.dig("audits", "max-potential-fid", "numericValue"),
              fmp: lh.dig("audits", "first-meaningful-paint", "numericValue"),
              fci: lh.dig("audits", "first-cpu-idle", "numericValue"),
              fcp: lh.dig("audits", "first-contentful-paint", "numericValue"),
              si: lh.dig("audits", "speed-index", "numericValue"),
              ia: lh.dig("audits", "interactive", "numericValue")
            }
          end

          payload = sort_by_fetch_time(payload)

          if params[:merge] && params[:merge] == "daily"
            payload = merge_days(payload)
          end

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        private
          def sort_by_fetch_time(arr)
            arr.sort_by { |a| DateTime.parse(a[:fetchTime]) }
          end

          # Merges all audit report KPI by arithmetic mean of the same day.
          #
          # Implicitly removes the Audit Report ID
          def merge_days(arr)
            merged = {}

            grouped = arr.group_by { |a| a[:day] }

            grouped.each do |day, entries|
              merged[day] = {}

              METRICS.each do |metric|
                merged[day][metric] = entries.map { |e| e[metric] }.mean
              end
            end

            merged.map { |day, data| { day: day }.merge(data) }
          end
      end
    end
  end
end
