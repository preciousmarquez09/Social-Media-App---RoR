class ApplicationController < ActionController::Base
    #for pagination
    include Pagy::Backend
    #check for configure permitted parameters for devise
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :notifications_counter, if: :user_signed_in?
    before_action :friend_request_counter, if: :user_signed_in?
    before_action :configure_sign_in_params, only: [:create], if: :devise_controller?
    before_action :search, if: :user_signed_in?
    

    private
    def search
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
      end
    end

    def friend_request_counter
       @friend_request_count = current_user.follow_requests
    end

    def notifications_counter
      @notifications = current_user.notifications.unread.order(created_at: :desc) || []
    end
    
    protected

    def after_sign_in_path_for(resource)
        puts "After sign in path called"
        posts_path
      end
    
      
    #for username or email login
    def configure_sign_in_params
        devise_parameter_sanitizer.permit(:sign_in, keys: [:login])
    end
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :username, :birthday, :gender, :admin, :bio, :avatar, :email])
        devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :username, :birthday, :gender, :admin, :bio, :avatar, :email, :remove_media ])
    end
end
