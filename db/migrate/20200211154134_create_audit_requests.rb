class CreateAuditRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :audit_requests do |t|
      t.jsonb :body, null: false, default: {}
      t.text :url
      t.integer :audit_type, null: false, default: 0

      t.timestamps
    end
  end
end
