class ChangeReadAtTypeInNotifications < ActiveRecord::Migration[6.0]
  def change
    change_column :notifications, :read_at, :datetime, using: 'NULLIF(read_at, 0)'
  end
end
