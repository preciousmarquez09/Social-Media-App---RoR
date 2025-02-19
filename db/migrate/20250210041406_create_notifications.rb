class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.string :action
      t.boolean :read, default: false
      t.json :params


      t.timestamps
    end
  end
end
