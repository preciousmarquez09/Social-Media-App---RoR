class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :notifications, dependent: :destroy
  validates :user, :post, presence: true
  validate :body_message

  private
  def body_message
    if body.blank?
      errors.add(:base, "Comment can't be empty! Please write something.")
    end
  end
end
