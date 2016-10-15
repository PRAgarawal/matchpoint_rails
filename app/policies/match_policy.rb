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
    return true if match.nil?
    show? && match.is_pending?
  end

  def leave?
    return true if match.nil?
    match.users.include?(user)
  end
end
