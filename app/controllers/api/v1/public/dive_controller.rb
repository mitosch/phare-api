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
        # audit:              audit, e.g.: "render-blocking-resources"
        # filter[field]:      field to query, e.g.: "url"
        # filter[query]:      string to look for
        def show
          # NOTE: currently not in use, only audits can be queried
          # type      = params[:type]     || "opportunity"
          audit = params[:audit] || "render-blocking-resources"

          page = Page.find(params[:page_id])

          payload = []
          page.audit_reports.each do |report|
            lh = report.body["lighthouseResult"]

            items = filtered_items(lh["audits"][audit]["details"]["items"])

            payload << {
              auditReportId: report.id,
              fetchTime: lh["fetchTime"],
              items: items
            }
          end

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        private
          # Filter items depending on given params
          #
          # Expected lighthouse items:
          # [{
          #     "url": "some_url",
          #     "wastedMs": 7200,
          #     "totalBytes": 560000
          # }, {
          #     "url": "another_url",
          #     "wastedMs": 2500,
          #     "totalBytes": 52300
          # }]
          def filtered_items(lighthouse_items)
            if  params[:filter] &&
                params[:filter][:field] &&
                !params[:filter][:query].empty?
              filter_field = params[:filter][:field]
              filter_query = params[:filter][:query]

              lighthouse_items.select do |item|
                item[filter_field].include?(filter_query)
              end
            else
              lighthouse_items
            end
          end
      end
    end
  end
end
