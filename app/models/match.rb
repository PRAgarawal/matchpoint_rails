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
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by_id'

  validates_with MaxPlayersValidator

  after_create :create_match_user

  scope :from_friends, -> {
    joins(:court).joins(:users).where('users.id IN (?)', User.friends.pluck(:id)) }
  scope :on_courts, -> {
    joins(:court).joins(:users).where('users.id' => User.current_user.id)
        .where(is_friends_only: false) }
  scope :available, -> { union_scope(from_friends, on_courts) }

  def is_pending?
    max_players = self.is_singles ? 2 : 4
    return self.users.count < max_players
  end

  def create_match_user
    self.update_attributes!(created_by_id: User.current_user.id)
    MatchUser.create!(user_id: self.created_by_id, match_id: self.id)
  end
end
