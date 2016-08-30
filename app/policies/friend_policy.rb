class FriendPolicy < Struct.new(:user, :friendship)
  class Scope < Struct.new(:user, :scope)
    def resolve
      user.friends
    end
  end

  def permitted_attributes_for_create
    [:invite_code, :email]
  end

  def permitted_attributes_for_update
    [:id, :is_confirmed]
  end

  def show?
    friend.user.id == user.id
  end

  def create?
    (friendship.invite_code.present? || friendship.email.present?) &&
    (friendship.invite_code != user.invite_code && friendship.email != user.email)
  end

  def update?
    friendship.friend_id == user.id
  end

  def destroy?
    friendship.friend_id == user.id || friendship.user_id == user.id
  end

end
