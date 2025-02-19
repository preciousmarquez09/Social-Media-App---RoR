class PostNotification < Noticed::Base
  # Add your delivery methods
  deliver_by :database #store to database
  deliver_by :action_cable #deliver real time notification

  param :user_id
  param :action #like or comment
  
  def message
    user = User.find_by(id: params[:user_id])
    #set the message based on the action
    if params[:action] == 'like'
      post = Post.find_by(id: params[:post_id])
      "#{user&.first_name} #{user&.last_name} liked your post!"
    elsif params[:action] == 'comment'
      post = Post.find_by(id: params[:post_id])
      comment = Comment.find_by(id: params[:comment_id])
      "#{user&.first_name} #{user&.last_name} commented on your post!"
    elsif params[:action] == 'follow'
      follow = User.find_by(id: params[:follow_id])
      "#{user&.first_name} #{user&.last_name} follows you!"
    elsif params[:action] == 'friend_req'
      follow = User.find_by(id: params[:follow_id])
      "#{user&.first_name} #{user&.last_name} sent you a friend request!"
    elsif params[:action] == 'accept_req'
      follow = User.find_by(id: params[:follow_id])
      "#{user&.first_name} #{user&.last_name} accepts your friend request!"
    end
  end
  
  def url
    if params[:action] == 'like' || params[:action] == 'comment'
      #access directly to routes
      Rails.application.routes.url_helpers.post_path(params[:post_id])
    else
      Rails.application.routes.url_helpers.home_path(params[:user_id])
    end
  end
end