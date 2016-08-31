class UserPolicy < Struct.new(:user, :user_object_to_authorize)
  class Scope < Struct.new(:user, :scope)
    def resolve
      user.friends
    end
  end

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

  def create_friendship?
    true
  end

  def accept_friendship?
    user.incoming_friends.include?(user_object_to_authorize)
  end

  def destroy_friendship?
    user.friends.include?(user_object_to_authorize)
  end
end
