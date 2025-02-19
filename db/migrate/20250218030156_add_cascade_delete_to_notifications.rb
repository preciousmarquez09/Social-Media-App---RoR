class AddCascadeDeleteToNotifications < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :notifications, :users
    add_foreign_key :notifications, :users, on_delete: :cascade
  end
end
