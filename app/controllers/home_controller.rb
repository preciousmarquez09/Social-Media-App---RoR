class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :set_user

  def index
    
  end
  #get the post of the user by getting the latest first 
  def show
    @user = User.find(params[:id])
    @pagy, @user_post = pagy(@user.posts.order(created_at: :desc), items: 2)
  end

  #get all of the friend request of the current user then limit the pagination to 2 (just to show the pagination)
  def show_friend_request
    @pagy, @friend_requests = pagy(current_user.follow_requests.order(id: :desc), items: 2)
  end
  
  #get all of the following, followers, and friends of the @user, im using @user since the following, followers, and friends is used a partial
  # where other user can see the following of one's account
  def lfollowing
    @pagy, @list_following = pagy(@user.following, items: 2)
  end

  def lfollowers
    @pagy, @list_followers = pagy(@user.followers, items: 2)
  end

  #get the friend_id first that the @user has a follow_type of "friend"
  def lfriends
    friends_ids = Followability::Relationship
                    .where(followerable: @user, follow_type: "friend")
                    .pluck(:followable_id)
  
    @pagy, @list_friends = pagy(User.where(id: friends_ids), items: 2)
  end  

  

  #follow the user
  def follow
    follow_user
    redirect_to home_path(@user)
  end

  #unfollow the user
  #once the current user unfollow the user, the user also unfollow the current user
  def unfollow
    make_it_a_unfriend_request
    current_user.unfollow(@user)
    redirect_to posts_path
  end

  #remove from the followers
  def remove
    @user.unfollow(current_user)
    redirect_to posts_path
  end

  #sent a friend request to user
  #if the current user is following the user it unfollow first since 
  #the followability only allows 1 status (send friend request, following)
  def friend_request
    current_user.unfollow(@user) if current_user.following?(@user)
      
    current_user.send_follow_request_to(@user)
    redirect_to home_path(@user)
  end

  #if the user accept the current user they unfollow each other first
  # then accept the friend request, then the @user also sends a follow request
  # then accept then update the follow_type to friends
  def accept
    current_user.unfollow(@user) if current_user.following?(@user)
    @user.unfollow(current_user) if @user.following?(current_user)
      
    follow_user

    @user.send_follow_request_to(current_user)
    current_user.accept_follow_request_of(@user)

    update_follow_type_to_friend(current_user, @user)
  
    redirect_to posts_path
  end
  
  #decline the follow request sent to user
  def decline
    current_user.decline_follow_request_of(@user)
    redirect_to posts_path
  end

  #if the user wants to remove the friend request
  def cancel
    current_user.remove_follow_request_for(@user)
    redirect_to posts_path
  end

  private
  
  #send and accept follow request for follow and accept friend request
  def follow_user
    current_user.send_follow_request_to(@user)
    @user.accept_follow_request_of(current_user)
  end

  #for unfollow
  def make_it_a_unfriend_request
    @user.unfollow(current_user) if @user.mutual_following_with?(current_user)
  end

  #accept the friend request then set the follow_type to friend 
  def update_follow_type_to_friend(user1, user2)
    ActiveRecord::Base.connection.execute("
      UPDATE followability_relationships
      SET follow_type = 'friend'
      WHERE (followerable_id = #{user1.id} AND followable_id = #{user2.id})
         OR (followerable_id = #{user2.id} AND followable_id = #{user1.id})
    ")
  end
  def set_user
    @user = User.find_by(id: params[:id])
  end
  
end
