class AddLastAuditedAtToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :last_audited_at, :datetime
  end
end
