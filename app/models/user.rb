class User < ApplicationRecord
  include RegexHelper
  include Friendable

  # This is a hack-y way to allow us to use a Friendship model for authorization in the UserPolicy
  attr_accessor :friendship_to_authorize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable

  validates :first_name, presence: true, length: {maximum: 255}
  validates :last_name, presence: true, length: {maximum: 255}
  validates :email, presence: true, format:
      {with: VALID_EMAIL_REGEX,
       message: "check email format"}, length: {maximum: 255}
  validates :skill, presence: true, inclusion: {in: 2..14}
  # validates :invited_by_id, presence: true, if: :is_not_root_user?
  # Using "is_male" has too many potential UI issues, so for `gender`, true if male, false if female
  validates :gender, inclusion: {in: [true, false]}

  before_create :create_invite_code
  after_create :create_friendship, if: :is_friend_code_signup?
  after_invitation_accepted :create_friendship
  before_validation :set_invited_by_id

  has_many :messages
  has_many :match_users
  has_many :chat_users
  has_many :court_users
  has_many :matches, through: :match_users
  has_many :chats, through: :chat_users
  has_many :courts, through: :court_users
  has_many :court_matches, through: :courts, source: :matches, class_name: 'Match'
  has_many :requested_courts, class_name: 'Court', foreign_key: 'requested_by_id'

  scope :friends, -> { where(Friendable.where_friend_clause(User.current_user.id)) }

  def friends
    User.find_by_sql "SELECT * FROM users AS friends
                        WHERE #{Friendable.where_friend_clause(self.id)}
                        ORDER BY friends.last_name ASC"
  end

  def incoming_friends
    User.find_by_sql "SELECT * FROM users AS friends
                        WHERE id IN (
                          SELECT user_id FROM friendships
                            WHERE friend_id = #{self.id} AND is_confirmed = false)
                        ORDER BY friends.last_name ASC"
  end

  #including unconfirmed
  def all_friends
    User.find_by_sql "SELECT * FROM users AS friends
                        WHERE id IN (
                          SELECT friend_id FROM friend_links
                            WHERE user_id = #{self.id})"
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
    if Friendship.friendship_for_friend(self.id, self.invited_by_id).nil?
      Friendship.create!(friend_id: self.id, user_id: self.invited_by_id, is_confirmed: true)
    end
  end

  def set_invited_by_id
    if self.invited_by_id.nil?
      inviter = User.find_by(invite_code: self.invited_by_code.to_s.upcase)
      self.invited_by_id = inviter.try(:id)
    end
  end

  def is_not_root_user?
    return !ENV['ROOT_INVITE_CODE'].upcase.to_s.split(',').include?(self.invited_by_code.to_s.upcase)
  end

  def is_friend_code_signup?
    return is_not_root_user? && self.invited_by_id.nil?
  end

  def friend_status(user = User.current_user)
    if !user.all_friends.include?(self)
      return 'no_friendship'
    elsif user.friends.include?(self)
      return 'friend'
    elsif user.incoming_friends.include?(self)
      return 'request_received'
    else
      return 'request_sent'
    end
  end

  def ui_skill
    return (self.skill.to_i/2.0).round(1)
  end

  def has_joined_courts
    return self.courts.count > 0 || self.requested_courts.count > 0
  end

  def is_admin
    return self.email == 'sri@matchpoint.us'
  end
end
