class Match < ApplicationRecord
  include UnionScopable

  has_many :match_users, dependent: :destroy
  has_many :users, through: :match_users
  has_one :chat
  belongs_to :court

  validates :match_date, presence: true
  validates :court, presence: true
  validate :max_players_not_exceeded

  after_create :create_initial_match_user_and_chat

  # All the current user's friends' matches
  scope :from_friends, -> {
    joins(:match_users)
        .where('match_users.user_id IN (?)', User.friends.pluck(:id))
        .distinct
  }
  scope :available_from_friends, -> { Match.filter_available_matches(from_friends) }
  # All public matches at the current user's courts
  scope :on_courts, -> {
    joins(:court)
        .joins("INNER JOIN court_users ON court_users.court_id = courts.id AND court_users.user_id" +
                   " = #{User.current_user.id}")
        .where(is_friends_only: false)
        .distinct }
  scope :available_on_courts, -> { Match.filter_available_matches(on_courts) }
  # Union of the above two, including all matches visible to the user
  scope :available, -> { union_scope(from_friends, on_courts) }

  def is_pending?
    max_players = self.is_singles ? 2 : 4
    return self.users.count < max_players
  end

  def create_initial_match_user_and_chat
    Chat.create!(match_id: self.id)
    MatchUser.create!(user_id: User.current_user.id, match_id: self.id)
  end

  def first_user
    return self.match_users.order(created_at: :desc).first.user
  end

  def max_players_not_exceeded
    if self.is_singles && self.users.count > 2
      self.errors[:base] << 'Singles match cannot have more than two players'
    end

    if !self.is_singles && self.users.count > 4
      self.errors[:base] << 'Doubles match cannot have more than four players'
    end
  end

  private

  # This should only really be called on the `from_friends` and `on_courts` scopes
  def self.filter_available_matches(scope)
    return scope.select('matches.*')
        .joins(:match_users)
        .group('matches.id')
        .where('matches.match_date >= CURRENT_DATE')
        .having('MAX(CASE WHEN match_users.user_id = ? THEN 1 ELSE 0 END) = 0',
                User.current_user.id)
        .having('COUNT(match_users.id) < (CASE WHEN matches.is_singles THEN 2 ELSE 4 END)')
        .order(match_date: :asc)
  end
end
