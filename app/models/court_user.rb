class CourtUser < ApplicationRecord
  belongs_to :court
  belongs_to :user

  after_create :set_user_is_dfw

  def set_user_is_dfw
    user.update_attributes!(is_dfw: court.is_dfw)
  end
end
