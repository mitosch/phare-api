# frozen_string_literal: true

# Serializer for +AuditReport+
class AuditReportSerializer
  include FastJsonapi::ObjectSerializer

  set_key_transform :camel_lower

  set_id :id
  attributes :audit_type, :summary

  attribute :lighthouse_result do |object|
    object.body["lighthouseResult"]
  end

  # attribute :summary, if: proc { |_record, params|
  #   params && params[:summary] == true
  # }
end
