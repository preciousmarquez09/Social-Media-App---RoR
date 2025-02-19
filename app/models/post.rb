class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :media
  has_many :comments, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :notifications, dependent: :destroy
  
  #include Visible
  validate :body_or_media_present

  #allows body for searching using ransack
  def self.ransackable_attributes(auth_object = nil)
    [ "body" ]
  end

  private
  def body_or_media_present
    unless body.present? || media.attached?
      errors.add(:base, "Please insert text, image, or photo")
    end
  end
end
