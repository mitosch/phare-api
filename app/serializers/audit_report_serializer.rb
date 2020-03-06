# frozen_string_literal: true

# Serializer for +AuditReport+
class AuditReportSerializer < ActiveModel::Serializer
  attributes :audit_type, :summary

  belongs_to :page

  # include FastJsonapi::ObjectSerializer
  #
  # set_key_transform :camel_lower
  #
  # set_type :audit_reports
  #
  # set_id :id
  # attributes :audit_type, :summary
  #
  # belongs_to :pages
  #
  # attribute :lighthouse_result do |object|
  #   object.body["lighthouseResult"]
  # end
  #
  # # attribute :summary, if: proc { |_record, params|
  # #   params && params[:summary] == true
  # # }
end
