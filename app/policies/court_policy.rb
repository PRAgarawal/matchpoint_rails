class CourtPolicy < Struct.new(:user, :court)
  class Scope < Struct.new(:user, :scope)
    def resolve
      Court.all
    end
  end
end
