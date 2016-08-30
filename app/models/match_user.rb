class MatchUser < ApplicationRecord
  belongs_to :match
  belongs_to :user

  before_destroy :destroy_match_if_last

  def destroy_match_if_last
    match.destroy! if match.users.count == 1
  end
end
