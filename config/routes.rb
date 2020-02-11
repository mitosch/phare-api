# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      scope module: "public", path: "pub" do
        # resources :audit_requests
      end
    end
  end
end
