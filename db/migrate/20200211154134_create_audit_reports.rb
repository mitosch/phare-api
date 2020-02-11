class CreateAuditReports < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_reports do |t|
      t.jsonb :body, null: false, default: {}
      t.integer :audit_type, null: false, default: 0

      t.timestamps
    end
  end
end
