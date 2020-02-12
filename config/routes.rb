# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      scope module: "public", path: "pub" do
        put :pages, to: "pages#create_or_update"

        post :audit_reports, to: "audit_reports#create"
      end
    end
  end
end
