class AddFollowToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :followability_relationships, null: true, foreign_key: true
  end
end
