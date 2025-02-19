  class AddCommentToNotifications < ActiveRecord::Migration[6.0]
    def change
      add_reference :notifications, :comment, null: true, foreign_key: true
    end
  end
