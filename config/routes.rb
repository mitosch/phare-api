# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      scope module: "public", path: "pub" do
        resources :pages, only: %i[index show] do
          resources :audit_reports, only: %i[index show]
        end

        put "pages", to: "pages#create_or_update"

        # NOTE: this will be deprecated and done in pages#show with a param
        get "pages/:page_id/statistics", to: "statistics#show"

        get "pages/:page_id/dive", to: "dive#show"

        post "audit_reports", to: "audit_reports#create"
      end
    end
  end
end
