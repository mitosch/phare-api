class AddSummaryToAuditReport < ActiveRecord::Migration[6.0]
  def change
    add_column :audit_reports, :summary, :jsonb
  end
end
