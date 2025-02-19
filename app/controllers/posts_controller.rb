class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Initialize the matching_users variable
    @matching_users = []
  
    # Initialize the Ransack search object
    @q = Post.includes(:user, :comments).order(created_at: :desc).ransack(params[:q])
  
    # Check if the search user is present for users
    if params[:q].present? && params[:q][:body_or_user_first_name_or_user_last_name_or_user_username_cont].present?
      search_user = params[:q][:body_or_user_first_name_or_user_last_name_or_user_username_cont].strip
      
      # Check if search_user is not empty
      if search_user.present?
        # Find users matching the search user using LIKE for MySQL, make the data to lowercase to ensure that it matches
        @matching_users = User.where("LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(username) LIKE ?", 
                                    "%#{search_user.downcase}%", "%#{search_user.downcase}%", "%#{search_user.downcase}%")
      end
    end
  
    if params[:q].present? && params[:q][:body_or_user_first_name_or_user_last_name_or_user_username_cont].present?
      # If the search term is not empty, fetch posts based on the search
      @pagy, @posts = pagy(@q.result(distinct: true))
    elsif current_user.admin?
      # If the user is an admin, fetch all posts
      @pagy, @posts = pagy(Post.includes(:user, :comments).order(created_at: :desc))
    else
      # Fetch posts of users following
      @pagy, @posts = pagy(Post.includes(:user, :comments).where(user: current_user.following).order(created_at: :desc))
    end
  end

  def show
    @post = Post.includes(:user, :comments).find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      redirect_to edit_post_path(@post), notice: 'Your post was shared'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])

    #if the hidden file is true (when media is removed it will delete to the database)
    if params[:post][:remove_media] == "true"
      @post.media.purge if @post.media.attached?
    end

    if @post.update(post_params)
      redirect_to @post
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
  
    if @post.destroy
      redirect_to posts_path, status: :see_other, notice: "Post deleted successfully."
    else
      redirect_to posts_path, alert: "Failed to delete post."
    end
  end
  
  private
    def post_params
      params.require(:post).permit(:body, :status, :media) 
    end
    
end
