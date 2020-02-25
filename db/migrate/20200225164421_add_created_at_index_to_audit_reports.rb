class AddCreatedAtIndexToAuditReports < ActiveRecord::Migration[6.0]
  def change
    add_index :audit_reports, :created_at, order: { created_at: :desc }
  end
end
