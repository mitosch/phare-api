# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for pages beeing monitored
      class PagesController < PublicController
        # include JSONAPI::ActsAsResourceController

        # SUMMARY_METRICS = {
        #   max_potential_fid: "max-potential-fid",
        #   first_meaningful_paint: "first-meaningful-paint",
        #   first_cpu_idle: "first-cpu-idle",
        #   first_contentful_paint: "first-contentful-paint",
        #   speed_index: "speed-index",
        #   interactive: "interactive"
        # }.freeze

        # GET /pub/pages
        #
        # Returns all pages
        def index
          # pages = PageSerializer.new(Page.all)
          pages = Page.all

          render json: pages
        end

        # GET /pub/pages/:page_id
        #
        # Returns a specific page
        def show
          page = Page.find(params[:id])

          render json: page,
                 include: include_params,
                 fields: sparse_fields
        rescue ActiveRecord::RecordNotFound
          render json: { error: "page not found" }, status: :not_found
        end

        # GET /pub/pages/:page_id/statistics
        #
        # Returns a specific page
        def statistics
          page = Page.find(params[:page_id])

          render json: page.statistics
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
            page.audit_frequency = page_params[:audit_frequency]
            page.save
          end
          PageAuditJob.perform_later(page)

          render json: page
        rescue URI::InvalidURIError
          render json: { error: "invalid url" }, status: :bad_request
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

          def include_params
            params[:include].present? &&
              params[:include].split(",").map(&:underscore)
          end

          # Returns a hash from params for generating a sparse fieldset
          # FIXME: Unpermitted parameters: :include, :key, :id
          def sparse_fields(defaults = {})
            result = params.permit(fields: {})[:fields]

            fieldset = result.to_h.map do |k, v|
              v = v.split(",").map(&:underscore) if v.is_a?(String)
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
      end
    end
  end
end
