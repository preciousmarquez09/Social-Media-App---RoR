class ChangeNotificationsUserAndPostNullable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notifications, :user_id, true
    change_column_null :notifications, :post_id, true
  end
end
