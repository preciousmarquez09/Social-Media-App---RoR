class Notification < ApplicationRecord
  include Noticed::Model

  belongs_to :recipient, polymorphic: true #used to accept different type of model
  belongs_to :user, optional: true  # Allow NULL at first
  belongs_to :post, optional: true
  belongs_to :comment, optional: true
  # after saving in the database call the method
  after_create_commit :assign_user_and_post  

  #find the unread notification (it has a null value)
  scope :unread, -> { where(read_at: nil) }

  private

  def mark_as_read
    update(read: true)
  end
  
  def assign_user_and_post
    return unless params.present?
  
    # Update the columns user_id, post_id, action, and optionally comment_id based on the passed params
    update_columns(
      user_id: params[:user_id],
      post_id: params[:post_id],
      action: params[:action],
      comment_id: params[:action] == 'comment' ? params[:comment_id] : nil
    )
  end
  
end
