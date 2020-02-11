# frozen_string_literal: true

module Api
  module V1
    # API functionalities for all endpoints.
    class ApiController < ApplicationController
      # def process_action(*args)
      #   super
      # rescue_from ActionDispatch::Http::Parameters::ParseError do |exception|
      #   render status: 400, json { errors: [ exception.cause.message ] }
      # end
    end
  end
end
