# frozen_string_literal: true

# Rails.application.routes.default_url_options[:host] = 'localhost:3000'

# Serializer for +Page+
class PageSerializer
  include FastJsonapi::ObjectSerializer

  set_key_transform :camel_lower

  set_id :id
  attributes :url, :status, :audit_frequency, :last_audited_at

  has_many :audit_reports, lazy_load_data: true, links: {
    self: lambda do |object|
      Rails.application.routes.url_helpers
           .api_v1_page_url(object.id)
    end,
    related: lambda do |object|
      Rails.application.routes.url_helpers
           .api_v1_page_audit_reports_url(object.id)
    end
  }
end
