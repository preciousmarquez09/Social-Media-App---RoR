class User < ApplicationRecord
  has_one_attached :avatar
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  
  followability
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  #validate login for using username or email
  attr_accessor :login
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email, presence: true, uniqueness: { case_sensitive: true }, format: { 
    with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]{3,}\z/i, message: "must be a valid email address" }
  
  before_destroy :destroy_notifications

  before_create :set_admin_if_first_user
  validates :birthday, :gender, presence: true 
  validates :first_name, presence: true, length: { minimum: 2 }, if: -> { first_name.present? }, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }
  validates :last_name, presence: true, length: { minimum: 2 }, if: -> { last_name.present? }, format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" }

  validates :username, presence: true, length: { minimum: 2 }, if: -> { username.present? }, 
                     format: { with: /\A[a-zA-Z0-9@._#]+\z/, message: "only allows letters, numbers, and @ . _ #" }


  validates :bio, length: { maximum: 100, too_long: "%{count} characters is the maximum allowed" }
  validate :age_is_16_above

  #for unfollow to destroy the matches user.id
  def unfollow(user)
    followerable_relationships.where(followable_id: user.id).destroy_all
  end
  
  #for ransack make the firstname lastname and username searchable
  def self.ransackable_attributes(auth_object = nil)
    [ "first_name", "last_name", "username" ]
  end

  #use binary to make it case sensitive and compare each character
  def self.find_for_authentication(conditions)
    login = conditions.delete(:login)
    where(conditions).where(["BINARY username = :value OR BINARY email = :value", { value: login }]).first
  end

  private

  #set the admin for the first user
  def set_admin_if_first_user
    if User.count == 0
      self.admin = true
    end
  end

  #validate age if 16 above
  def age_is_16_above
    if birthday.present? && birthday > 16.years.ago.to_date
      errors.add(:base, "Must be at least 16 years old")
    end
  end

  def destroy_notifications
    Rails.logger.info "Destroying notifications for user #{self.id}"
    notifications.delete_all
  end
  
end
