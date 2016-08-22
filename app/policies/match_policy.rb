class MatchPolicy < Struct.new(:user, :match)
  class Scope < Struct.new(:user, :scope)
    def resolve
      # All public matches at the users courts and all
      Match.available
    end
  end

  def permitted_attributes_for_create
    [:match_date, :court_id, :is_singles, :is_friends_only]
  end

  def permitted_attributes_for_update
    [:match_date, :is_singles]
  end

  def show?
    Match.available.include?(match)
  end

  def create?
    user.courts.include?(match.court)
  end

  def update?
    user.matches.include?(match)
  end

  def destroy?
    user.created_matches.include?(match)
  end

  def join?
    show?
  end
end
