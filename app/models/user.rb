class User < ApplicationRecord
  include RegexHelper

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, presence: true, length: {maximum: 255}
  validates :last_name, presence: true, length: {maximum: 255}
  validates :email, presence: true, format:
      {with: VALID_EMAIL_REGEX,
       message: "check email format"}, length: {maximum: 255}

  has_many :messages
  has_many :match_users
  has_many :chat_users
  has_many :court_users
  has_many :friendships, foreign_key: 'user_id'
  has_many :matches, through: :match_users
  has_many :chats, through: :chat_users
  has_many :courts, through: :court_users
  has_many :court_matches, through: :courts, source: :matches, class_name: 'Match'
  has_many :friends, through: :friendships, class_name: 'User'
end
