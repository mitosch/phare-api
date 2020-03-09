# frozen_string_literal: true

# Serializer for +AuditReport+
class AuditReportSerializer
  include SimpleSerializer::ObjectSerializer

  attributes :id, :audit_type, :summary

  attribute :body do |report, params|
    params && params[:with_body] ? report.body : nil
  end
end
