class AddAuditFrequencyToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :audit_frequency, :integer, null: false, default: 0
  end
end
