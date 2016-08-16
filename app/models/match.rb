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
  has_many :match_users
  has_many :users, through: :match_users
  has_one :chat
  belongs_to :court

  validates_with MaxPlayersValidator

  def is_pending?
    max_players = self.is_singles ? 2 : 4
    return self.users.count < max_players
  end
end
