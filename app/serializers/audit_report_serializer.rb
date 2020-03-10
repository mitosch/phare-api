# frozen_string_literal: true

# Serializer for +AuditReport+
class AuditReportSerializer
  include SimpleSerializer::ObjectSerializer

  attributes :id, :audit_type, :summary

  attribute :lighthouse_result do |report, params|
    params && params[:with_body] ? report.lighthouse_result : nil
  end
end
