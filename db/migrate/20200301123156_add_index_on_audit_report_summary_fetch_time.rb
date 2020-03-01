class AddIndexOnAuditReportSummaryFetchTime < ActiveRecord::Migration[6.0]
  def change
    add_index :audit_reports, "(summary->>'fetchTime')"
  end
end
