# frozen_string_literal: true

# Serializer for +Page+
class PageSerializer < ActiveModel::Serializer
  attributes :url, :status, :audit_frequency, :last_audited_at

  has_many :audit_reports

  # include FastJsonapi::ObjectSerializer
  # set_key_transform :camel_lower
  #
  # set_type :pages
  #
  # set_id :id
  # attributes :url, :status, :audit_frequency, :last_audited_at
  #
  # has_many  :audit_reports,
  #           record_type: :auditReports,
  #           if: proc { |_record, params|
  #             include_model?(params, :audit_reports)
  #           },
  #           serializer: AuditReportSerializer
  #
  # def self.include_model?(params, model)
  #   params[:include].present? && params[:include].include?(model)
  # end
end
