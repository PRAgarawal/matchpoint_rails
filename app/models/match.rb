class MaxPlayersValidator < ActiveModel::Validator
  def validate(record)
    if record.is_singles && record.users.count > 2
      record.errors[:base] << 'Singles match cannot have more than two players'
    end

    if !record.is_singles && record.users.count > 4
      record.errors[:base] << 'Doubles match cannot have more than four players'
    end
  end
end

class Match < ApplicationRecord
  include UnionScopable

  has_many :match_users
  has_many :users, through: :match_users
  has_one :chat
  belongs_to :court

  validates_with MaxPlayersValidator
  validates :match_date, presence: true
  validates :court, presence: true

  after_create :create_initial_match_user

  # All the current user's friends' matches
  scope :from_friends, -> {
    joins(:match_users)
        .where('match_users.user_id IN (?)', User.friends.pluck(:id))
        .distinct
  }
  # All public matches at the current user's courts
  scope :on_courts, -> {
    joins(:court)
        .joins("INNER JOIN court_users ON court_users.court_id = courts.id AND court_users.user_id" +
                   " = #{User.current_user.id}")
        .where(is_friends_only: false)
        .distinct }
  # Union of the above two, including all matches visible to the user
  scope :available, -> { union_scope(from_friends, on_courts) }

  def is_pending?
    max_players = self.is_singles ? 2 : 4
    return self.users.count < max_players
  end

  def create_initial_match_user
    MatchUser.create!(user_id: User.current_user.id, match_id: self.id)
  end

  def first_user
    return self.match_users.order(created_at: :desc).first.user
  end
end
