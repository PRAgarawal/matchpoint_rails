class User < ApplicationRecord
  include RegexHelper
  include Friendable

  # This is a hack-y way to allow us to use a Friendship model for authorization in the UserPolicy
  attr_accessor :friendship_to_authorize, :court_code

  # Include default devise modules. Others available are:
  #  :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

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
  after_create :join_court, if: :is_court_code_signup?
  after_create :create_friendship, if: :is_friend_code_signup?
  after_invitation_accepted :create_friendship

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
    self.set_invited_by_id
    if Friendship.friendship_for_friend(self.id, self.invited_by_id).nil?
      Friendship.create!(friend_id: self.id, user_id: self.invited_by_id, is_confirmed: true)
    end
  end

  def set_invited_by_id
    if self.invited_by_id.nil?
      inviter = User.find_by(invite_code: self.invited_by_code.to_s.upcase)
      update_attributes!(invited_by_id: inviter.try(:id))
    end
  end

  def is_not_root_user?
    return !ENV['ROOT_INVITE_CODE'].upcase.to_s.split(',').include?(self.invited_by_code.to_s.upcase)
  end

  DEFAULT_INVITE_CODE = 'INIT'

  def is_friend_code_signup?
    return is_not_root_user? && self.invited_by_id.nil? && self.invited_by_code != DEFAULT_INVITE_CODE && self.invited_by_code.present?
  end

  def is_court_code_signup?
    return Court.find_by(court_code: self.court_code).present?
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
    case self.skill
      when 8 then return "Pro"
      when 7 then return "Open"
      when 6 then return "Elite"
      when 5 then return "A"
      when 4 then return "B"
      when 3 then return "C"
      when 2 then return "D"
    end
  end

  def has_joined_courts
    return self.courts.count > 0
  end

  def is_admin
    return self.email == 'sri@matchpoint.us'
  end

  def join_court
    court = Court.find_by(court_code: self.court_code)
    CourtUser.create(court_id: court.id, user_id: self.id)
  end

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def record
    wins = MatchUser.where(user_id: self.id, is_winner: true).count
    losses = MatchUser.where(user_id: self.id, is_winner: false).count
    return "#{wins}-#{losses}"
  end

  def self.update_scores
    ActiveRecord::Base.connection.execute('
      UPDATE users
      SET score = (SELECT COUNT(matches.id) FROM (
          SELECT matches.id
          FROM users AS u
          LEFT JOIN match_users mu1 ON mu1.user_id = u.id
          LEFT JOIN matches ON matches.id = mu1.match_id
          LEFT JOIN match_users mu2 ON mu2.match_id = matches.id
          WHERE (date_trunc(\'month\', matches.match_date) = date_trunc(\'month\', now()))
              AND matches.match_date < now()
              AND u.id = users.id
          GROUP BY matches.id
          HAVING COUNT(matches.id) = (CASE WHEN matches.is_singles THEN 2 ELSE 4 END)
      ) AS matches);
    ')
  end
end
