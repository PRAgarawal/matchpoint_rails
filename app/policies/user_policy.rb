class UserPolicy < Struct.new(:user, :user_object_to_authorize)
  class Scope < Struct.new(:user, :scope)
    def resolve
      user.friends
    end
  end

  def permitted_attributes
    return [
        :id, :first_name, :last_name, :email, :phone, :password, :password_confirmation, :gender
    ]
  end

  def permitted_attributes_for_update
    permitted_attributes
  end

  def show?
    true
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

  def invite_friend?
    true
  end

  def accept_friendship?
    friendship = user.friendship_to_authorize
    return true if friendship.nil?
    friendship.user == user_object_to_authorize && friendship.friend == user
  end

  def destroy_friendship?
    friendship = user.friendship_to_authorize
    return true if friendship.nil?
    friendship.user == user || friendship.friend == user
  end
end
