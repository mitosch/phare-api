# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for pages beeing monitored
      class PagesController < PublicController
        # GET /pub/pages
        #
        # Returns all pages
        def index
          payload = []

          pages = Page.all

          # search
          if params[:filter] && params[:filter][:url]
            pages = pages.where("url LIKE ?", "%#{params[:filter][:url]}%")
          end

          if params[:include] && params[:include] == "label"

            if params[:filter] && params[:filter][:label]
              label_id = params[:filter][:label].to_i
              pages = pages
                      .includes(:label)
                      .where(label_pages: { label_id: label_id })
            else
              pages = pages.includes(:label)
            end

            pages.each do |page|
              entry = PageSerializer.new(page).serializable_hash
              entry[:label] = LabelSerializer.new(page.label).serializable_hash
              payload << entry
            end
          else
            payload = PageSerializer.new(pages).serialized_json
          end

          render json: payload
        end

        # GET /pub/pages/:id
        #
        # Returns a specific page
        def show
          payload = {}

          page = Page.find(params[:id])

          if params[:include] && params[:include] == "label"
            label = LabelSerializer.new(page.label).serializable_hash
            payload = PageSerializer.new(page).serializable_hash
            payload[:label] = label
          else
            payload = PageSerializer.new(page).serialized_json
          end

          render json: payload
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        # GET /pub/pages/:page_id/statistics
        #
        # Returns statistics about a specific page
        def statistics
          page = Page.find(params[:page_id])

          start_date = (parse_date(params[:startDate]) || default_date(:start)) + "T00:00"
          end_date = (parse_date(params[:endDate]) || default_date(:end)) + "T24:00"

          render json: page.statistics(start_date, end_date)
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        # PUT /pub/pages
        #
        # Adds an URL to the queue or requeues it, if it already exists.
        def create_or_update
          uri = parse_url(page_params[:url])

          page = Page.find_or_create_by(url: uri.to_s)
          # OPTIMIZE: check if possible above with block...
          if page_params[:audit_frequency]
            # TODO: camelize param
            page.audit_frequency = page_params[:audit_frequency]
            page.save
          end
          PageAuditJob.perform_later(page)

          render json: PageSerializer.new(page).serialized_json
        rescue URI::InvalidURIError
          render json: { error: "invalid url" }, status: :bad_request
        end

        # PUT /pub/pages/:page_id/label
        #
        # Updates a pages and sets a label
        #
        # Expected payload:
        #
        # {
        #   label: { id: 1234 }
        # }
        #
        # if label id is -1, it will be removed from page
        #
        # TODO: return serialized json with label
        def update_label
          unless params[:label] && params[:label][:id]
            render json: { error: "invalid payload" }, status: :bad_request
            return
          end

          # assign label only, if id is > 0,
          # else label will be nil and deleted
          label = if params[:label][:id]&.to_i&.positive?
                    Label.find(params[:label][:id])
                  end

          page = Page.find(params[:page_id])

          page.label = label
          if page.save
            render json: PageSerializer.new(page).serialized_json
          else
            render json: page.errors, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: "record not found" }, status: :not_found
        end

        private
          def page_params
            params.permit(%i[url audit_frequency])
          end

          # TODO: DRY (audit_reports_controller) -> move to Page model valid.
          def parse_url(url)
            unless url.start_with?("http://", "https://")
              raise URI::InvalidURIError, "Invalid URL", url
            end

            URI.parse(url)
          end

          # TODO: DRY (audit_reports_controller)
          def default_date(type)
            count = case type
                    when :start then 7
                    when :end then 0
                    end

            (Time.now.utc - count.days).strftime("%Y-%m-%d")
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
