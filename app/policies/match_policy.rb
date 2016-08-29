class MatchPolicy < Struct.new(:user, :match)
  class Scope < Struct.new(:user, :scope)
    def resolve
      Match.available
    end
  end

  def permitted_attributes_for_create
    [:match_date, :court_id, :is_singles, :is_friends_only]
  end

  def permitted_attributes_for_update
    [:id, :match_date]
  end

  def show?
    Match.available.include?(match)
  end

  def create?
    user.courts.include?(match.court)
  end

  def update?
    match.first_user.id == user.id
  end

  def destroy?
    update?
  end

  def join?
    show? && match.is_pending?
  end

  def leave?
    match.users.include?(user)
  end
end
