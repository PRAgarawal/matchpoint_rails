class MatchPolicy < Struct.new(:user, :match)
  class Scope < Struct.new(:user, :scope)
    def resolve
      Match.available
    end
  end

  def permitted_attributes_for_create
    [:match_date, :court_id, :is_singles]
  end

  def permitted_attributes_for_update
    # Can only record scores for completed singles matches that do not yet have a score, and that are no more than two days old
    # TODO: Set a max score recording number on the match model
    if match.is_singles &&
        (match.match_date < Time.now) &&
        (match.match_date > 2.days.ago) &&
        (match.match_users.count == 2) &&
        match.users.include?(user) &&
        (match.match_users.first.is_winner == nil)
      return [
          :id, :match_date, :score_submitter_id, match_users_attributes:
          [
              :id, :is_winner, :set_1_total, :set_2_total, :set_3_total, :set_4_total, :set_5_total
          ]
      ]
    else
      return [:id, :match_date]
    end
  end

  def show?
    Match.available.include?(match)
  end

  def create?
    user.courts.include?(match.court)
  end

  def update?
    # TODO: May need more permissions to only allow first user to edit?
    match.users.include?(user)
  end

  def destroy?
    update?
  end

  def join?
    return true if match.nil?
    show? && match.is_pending?
  end

  def leave?
    return true if match.nil?
    match.users.include?(user)
  end
end
