class CommentsController < ApplicationController

    def create
        #initialize and create comment using build
        @post = Post.includes(:user).find(params[:post_id])
        @comment = @post.comments.build(comment_params)
        @comment.user = current_user
      
        if @comment.save
          #check current user and the owner of the post to avoid notification
          if current_user != @post.user
          #after saving the comment it calls the notification to save the user_id and post_id and the action is comment
            PostNotification.with(user_id: current_user.id, post_id: @post.id, comment_id: @comment.id, action: 'comment').deliver_later(@post.user)
          end
          redirect_to post_path(@post), notice: "Comment added successfully."
        else
          redirect_to post_path(@post), alert: @comment.errors.full_messages.to_sentence
        end
    end
    
    def show
      #destroy comment in show since it doesnt work with destroy method name
      @post = Post.find(params[:post_id])
      @comment = @post.comments.find(params[:id])

      # i commented the notification since i dont have any solution yet to delete the specific comment
      #notification = Notification.where(post: @post.id, user: current_user.id, action: 'comment').first
      #if notification
        #notification.destroy
      #end
      
        @comment.destroy
        redirect_to post_path(@post), notice: "Comment deleted successfully."
    end
    
    private
    def comment_params
        params.require(:comment).permit(:body)
    end
end
