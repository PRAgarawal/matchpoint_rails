class CourtPolicy < Struct.new(:user, :court)
  class Scope < Struct.new(:user, :scope)
    def resolve
      Court.all
    end
  end

  def join?
    !user.courts.include?(court)
  end

  def leave?
    user.courts.include?(court)
  end
end
