class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.text :url
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
