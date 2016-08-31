class User < ApplicationRecord
  include RegexHelper
  include Friendable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  validates :first_name, presence: true, length: {maximum: 255}
  validates :last_name, presence: true, length: {maximum: 255}
  validates :email, presence: true, format:
      {with: VALID_EMAIL_REGEX,
       message: "check email format"}, length: {maximum: 255}

  before_create :create_invite_code
  after_create :create_friendship
  after_invitation_accepted :create_friendship

  has_many :messages
  has_many :match_users
  has_many :chat_users
  has_many :court_users
  has_many :matches, through: :match_users
  has_many :chats, through: :chat_users
  has_many :courts, through: :court_users
  has_many :court_matches, through: :courts, source: :matches, class_name: 'Match'

  scope :friends, -> { where(Friendable.where_friend_clause(User.current_user.id)) }

  def friends
    User.find_by_sql "SELECT * FROM users AS friends
                        WHERE #{Friendable.where_friend_clause(self.id)}
                        ORDER BY friends.first_name ASC"
  end

  def incoming_friends
    User.find_by_sql 'SELECT friends.* FROM users
                        INNER JOIN friendships ON friendships.friend_id = users.id
                        INNER JOIN users AS friends ON friends.id = friendships.user_id
                        WHERE friendships.is_confirmed = false
                        ORDER BY friends.first_name ASC'
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

  def create_invite_code
    code_length = 5
    # Random, 5-character, alphanumeric string
    self.invite_code = rand(36**14).to_s(36)[0..code_length-1].upcase
  end

  def create_friendship
    if self.invited_by_code.present?
      user = User.find_by(invite_code: self.invited_by_code)
      Friendship.create!(friend_id: self.id, user_id: user.id, is_confirmed: true)
    elsif self.invited_by_id.present?
      Friendship.create!(friend_id: self.id, user_id: self.invited_by_id, is_confirmed: true)
    end
  end
end
