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
        # Looks for items in given type where field include query string
        #
        # params:
        #
        # type:   audit type, e.g.: "opportunity"
        # field:  field to query, e.g.: "url"
        # q:      string to look for
        def show
          type  = params[:type]   || "opportunity"
          field = params[:field]  || "url"
          query = params[:q]

          if query.blank?
            render json: { error: "no query given" }, status: :bad_request
            return
          end

          page = Page.find(params[:page_id])

          payload = []
          page.audit_reports.each do |report|
            lh = report.body["lighthouseResult"]

            lh["audits"].each do |key, audit|
              next unless audit["details"] &&
                          audit["details"]["type"] == type

              next if audit["details"]["items"].blank?

              audit["details"]["items"].each do |item|
                if item[field]&.include?(query)
                  payload << { auditReportId: report.id, key: key, type: type }.merge(item)
                end
              end
            end
          end

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end
      end
    end
  end
end
