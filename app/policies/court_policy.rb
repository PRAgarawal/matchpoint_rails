class CourtPolicy < Struct.new(:user, :court)
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.is_admin
        Court.all
      else
        Court.where(is_confirmed: true)
      end
    end
  end

  def permitted_attributes_for_create
    return [
        :id, :name, :requested_by_id,
        postal_address_attributes: [
            :id, :street, :state, :city, :zip
        ]
    ]
  end

  def permitted_attributes_for_update
    permitted_attributes_for_create.push(:is_confirmed)
  end

  def create?
    true
  end

  def update?
    # Only Sri can update courts (or mark them as confirmed)
    user.is_admin
  end

  def join?
    true
  end

  def leave?
    true
  end
end
