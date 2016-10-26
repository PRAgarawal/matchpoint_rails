class Match < ApplicationRecord
  include UnionScopable

  has_many :match_users
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
        .where('match_users.user_id IN (?)', User.friends.pluck(:id).push(User.current_user.id))
        .distinct
  }
  scope :available_from_friends, -> { Match.filter_available_matches(from_friends, true) }
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

  # This should only really be called on the `from_friends` and `on_courts` scopes
  def self.filter_available_matches(scope, from_friends = false)
    match_users_alias = from_friends ? 'mu' : 'match_users';
    return scope.select('matches.*')
        .joins("INNER JOIN match_users #{match_users_alias} ON #{match_users_alias}.match_id = matches.id")
        .group('matches.id')
        .where('matches.match_date >= ?', Time.now)
        .having('MAX(CASE WHEN match_users.user_id = ? THEN 1 ELSE 0 END) = 0',
                User.current_user.id)
        .having("COUNT(#{match_users_alias}.id) < (CASE WHEN matches.is_singles THEN 2 ELSE 4 END)")
        .order(match_date: :asc)
  end

  def get_player_list
    players = ''
    player_count = self.users.count

    self.users.each_with_index do |player, i|
      players += "#{player.first_name} (#{player.ui_skill})"
      players += ', ' if i < player_count - 1
    end

    return players
  end

  def formatted_match_date
    return self.match_date.in_time_zone('America/Chicago').strftime('%a, %b %-d at %-l:%M %p %Z')
  end
end
