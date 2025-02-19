class NotificationController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get all notifications for the current user
    @pagy, @all_notifications = pagy(current_user.notifications.order(created_at: :desc), items: 5)
  
    # Group notifications by date
    @grouped_notifications = @all_notifications.group_by { |notification| notification.created_at.to_date }
  end

  def read_and_redirect
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read! # Mark the notification as read
    if notification.action == 'like' || notification.action == 'comment'
      # Redirect to the post's show page
      redirect_to post_path(notification.params[:post_id])
    else
      redirect_to home_path(notification.params[:user_id])
    end
  end
  
  
end
