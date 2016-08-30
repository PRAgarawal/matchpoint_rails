class FriendsController < RestfulController

  def index_scope(scope)
  end

  def create
    email = params[:email]
    invite_code = params[:invite_code]

    user = nil
    user = User.find_by(email: email) if email.present?
    user = User.find_by(invite_code: invite_code) if invite_code.present?

    if user.nil?
      if invite_code.present? || !email.present?
        render json: {error: { detail: "Unable to find a user by that invite code" }},
               :status => :forbidden
      else
        # TODO: The user entered an email that isn't yet on the system, so let's send them an invite

      end
    else
      Friendship.create(user_id: current_user.id, friend_id: user.id)
      render json: {error: { detail: "Unable to find a user by that invite code" }},
             :status => :forbidden
    end
  end

  def destroy
  end

  def render_records(friends)
    render json: friends, only: [:id, :is_confirmed], include: [
        friend: {only: [:id, :first_name, :last_name, :skill]}]
  end
end
