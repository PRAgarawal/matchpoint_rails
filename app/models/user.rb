class User < ApplicationRecord
  include RegexHelper
  include Friendable

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
  has_many :matches, through: :match_users
  has_many :chats, through: :chat_users
  has_many :courts, through: :court_users
  has_many :court_matches, through: :courts, source: :matches, class_name: 'Match'
  has_many :created_matches, class_name: 'Match', foreign_key: 'created_by_id'

  scope :friends, -> { where(Friendable.where_friend_clause(User.current_user.id)) }

  def friends
    User.find_by_sql "SELECT * FROM users WHERE " + Friendable.where_friend_clause(self.id)
  end

  # See:
  # https://amitrmohanty.wordpress.com/2014/01/20/how-to-get-current_user-in-model-and-observer-rails/
  # It is generally not a good idea to try to access the current user from within the context
  # of a model, but right now, it seems that this is the only way to retrieve certain user-specific
  # data with our schema. Use this method sparingly...?
  def self.current_user
    Thread.current[:user]
  end

  def self.current_user=(user)
    Thread.current[:user] = user
  end
end
