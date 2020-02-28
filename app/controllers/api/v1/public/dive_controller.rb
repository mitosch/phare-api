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
        # startDate:          string of start date, format: YYYY-MM-DD
        # endDate:            string of end date, format: YYYY-MM-DD
        def show
          # NOTE: currently not in use, only audits can be queried
          # type      = params[:type]     || "opportunity"

          start_date = parse_date(params[:startDate]) || default_date(:start)
          end_date = parse_date(params[:endDate]) || default_date(:end)

          # NOTE: gsub is needed to not run into a PG syntax error
          audit = ActiveRecord::Base
                  .sanitize_sql(params[:audit])
                  .gsub("'", "''") || "render-blocking-resources"

          page = Page.find(params[:page_id])

          payload = []
          page
            .audit_reports
            .select(:id,
                    "summary->'fetchTime' as fetch_time",
                    "body->'lighthouseResult'->'audits'->" \
                    "'#{audit}'->'details'->'items' as items")
            .where("summary->>'fetchTime' >= ?", start_date)
            .where("summary->>'fetchTime' <= ?", end_date)
            .each do |report|
            items = filtered_items(report.items)

            payload << {
              auditReportId: report.id,
              fetchTime: report.fetch_time,
              items: items
            }
          end

          render json: payload
        rescue DateParseError
          render json: {
            error: "invalid date. required format: YYYY-MM-DD"
          }, status: :bad_request
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
            return [] unless lighthouse_items

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

          def default_date(type)
            count = case type
                    when :start then 7
                    when :end then 0
                    end

            time_string = case type
                          when :start then "T00:00"
                          when :end then "T24:00"
                          end

            date_string = (Time.now.utc - count.days).strftime("%Y-%m-%d")

            date_string + time_string
          end

          def parse_date(param)
            return false unless param
            return Date.parse(param).strftime("%Y-%m-%d") if valid_date?(param)

            raise DateParseError
          end

          def valid_date?(string)
            year, month, day = string.split("-")
            Date.valid_date?(year.to_i, month.to_i, day.to_i)
          end
      end

      class DateParseError < StandardError; end
    end
  end
end
