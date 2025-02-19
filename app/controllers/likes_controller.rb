class LikesController < ApplicationController

  #save the like to database using user id and post id
  def create
    @like = current_user.likes.new(like_params)
    @post = @like.post 
  
    if @like.save
      #check current user and the owner of the post to avoid notification
      #sent a notification by passing user id, post id and the action is like then the recipient is the owner of the post
      if current_user != @post.user
        PostNotification.with(user_id: current_user.id, post_id: @post.id, action: 'like').deliver_later(@post.user)
      end
      redirect_to @post
    else
      redirect_to @post, alert: @like.errors.full_messages.to_sentence
    end
  end
  

  def destroy

    #unlike the post
    @like = current_user.likes.find(params[:id])
    post = @like.post

    #if the user unlike the post, it removes the notification
    notification = Notification.where(post: post.id, user: current_user.id, action: 'like').first
  
    if notification
      notification.destroy
    end

    @like.destroy
    
    redirect_to post
  end

  private

  def like_params
    params.require(:like).permit(:post_id)
  end
end
