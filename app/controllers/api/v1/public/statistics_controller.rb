# frozen_string_literal: true

require "standard_deviation"

module Api
  module V1
    module Public
      # API endpoint for getting statistics of a page by daily avarage
      #
      # NOTE: This endpoint will be deprecated and replaced by page#show
      class StatisticsController < PublicController
        # METRICS = %i[mpf fmp fci fcp si ia].freeze
        SUMMARY_METRICS = {
          max_potential_fid: "max-potential-fid",
          first_meaningful_paint: "first-meaningful-paint",
          first_cpu_idle: "first-cpu-idle",
          first_contentful_paint: "first-contentful-paint",
          speed_index: "speed-index",
          interactive: "interactive"
        }.freeze

        # GET /pub/pages/:page_id/statistics
        def show
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

        private
          def prepare_selected_fields
            select_fields = [
              "TO_DATE(body->'lighthouseResult'" \
              "->>'fetchTime', 'YYYY-MM-DD') AS day"
            ]

            SUMMARY_METRICS.each do |key, metric|
              select_fields.push("AVG(CAST(body->'lighthouseResult'" \
                                 "->'audits'->'#{metric}'->>'numericValue' " \
                                 "AS FLOAT)) AS #{key}")
            end

            select_fields
          end
      end
    end
  end
end
