class PostNotification < Noticed::Base
  # Add your delivery methods
  deliver_by :database #store to database
  deliver_by :action_cable #deliver real time notification

  param :post_id
  param :user_id
  param :action #like or comment
  
  def message
    user = User.find_by(id: params[:user_id])
    #set the message based on the action
    if params[:action] == 'like'
      "#{user&.first_name} #{user&.last_name} liked your post!"
    elsif params[:action] == 'comment'
      comment = Comment.find_by(id: params[:comment_id])
      "#{user&.first_name} #{user&.last_name} commented on your post!"
    end
  end
  
  def url
    #access directly to routes
    Rails.application.routes.url_helpers.post_path(params[:post_id])
  end
end