class AddReferenceToAuditReport < ActiveRecord::Migration[6.0]
  def change
    add_reference :audit_reports, :page, null: false, foreign_key: true
  end
end
