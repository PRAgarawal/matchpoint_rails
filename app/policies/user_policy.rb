class UserPolicy < Struct.new(:user, :user_object_to_authorize)
  def permitted_attributes
    return [
        :id, :first_name, :last_name, :email, :phone, :password, :password_confirmation
    ]
  end

  def show?
    user == user_object_to_authorize
  end

  def update?
    show?
  end

  def destroy?
    update?
  end
end
