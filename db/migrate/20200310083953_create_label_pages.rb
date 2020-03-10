class CreateLabelPages < ActiveRecord::Migration[6.0]
  def change
    create_table :label_pages do |t|
      t.references :label, null: false, foreign_key: true
      t.references :page, null: false, foreign_key: true
    end
  end
end
