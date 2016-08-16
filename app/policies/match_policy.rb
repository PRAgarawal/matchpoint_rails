class MatchPolicy < Struct.new(:user, :match)
  class Scope < Struct.new(:user, :scope)
    def resolve
      user.court_matches
    end
  end

  def permitted_attributes
  end

  def show?
  end

  def create?
  end

  def update?
  end

  def destroy?
    update?
  end
end