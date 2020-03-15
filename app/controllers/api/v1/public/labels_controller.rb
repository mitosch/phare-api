# frozen_string_literal: true

module Api
  module V1
    module Public
      # API endpoint for labels being assigned to pages
      class LabelsController < PublicController
        # GET /pub/labels
        #
        # Returns all labels
        def index
          labels = Label.all

          render json: LabelSerializer.new(labels).serialized_json
        end

        # GET /pub/labels/:id
        #
        # Returns a specific label
        def show
          label = Label.find(params[:id])

          render json: LabelSerializer.new(label).serialized_json
        rescue ActiveRecord::RecordNotFound
          render json: { error: "label not found" }, status: :not_found
        end

        # POST /pub/labels
        #
        # Adds a new label
        def create
          label = Label.new(label_params)

          if label.save
            render json: LabelSerializer.new(label).serialized_json,
                   status: :created
          else
            render json: label.errors, status: :unprocessable_entity
          end
        end

        # PUT /pub/labels/:id
        #
        # Update label attributes
        def update
          label = Label.find(params[:id])

          if label.update(label_params)
            render json: LabelSerializer.new(label).serialized_json, status: :ok
          else
            render json: label.errors, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: "label not found" }, status: :not_found
        end

        # DELETE /pub/labels/:id
        #
        # Delete label
        #
        # TODO: yes
        #def destroy
        #end

        private
          def label_params
            params.permit(%i[name color])
          end
      end
    end
  end
end
