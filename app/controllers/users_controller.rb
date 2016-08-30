class UsersController < RestfulController
  # For rendering friends
  def index_scope(scope)
    requests = params[:requests]
    
    # return unconfirmed friend requests
    if requests == "true"
      
    # default to just returning confirmed friends
    else
    end
  end

  def create_friendship
    email = params[:email]
    invite_code = params[:invite_code]

    user = nil
    user = User.find_by(email: email) if email.present?
    user = User.find_by(invite_code: invite_code) if invite_code.present?

    if user.nil?
      if invite_code.present? || !email.present?
        render json: {error: { detail: "Unable to find a user by that invite code" }},
               status: :forbidden
      else
        # TODO: The user entered an email that isn't yet on the system, so let's send them an invite

      end
    else
      authorize user, :create_friendship?
      Friendship.create(user_id: current_user.id, friend_id: user.id)
      render json: {error: { detail: "Unable to find a user by that invite code" }},
             status: :forbidden
    end
  end

  def accept_friendship
    update_friendship do |friendship|
      authorize friendship, :accept_friendship?
      friendship.update_attributes!(is_confirmed: true)
    end
  end

  def destroy_friendship
    update_friendship do |friendship|
      authorize friendship, :destroy_friendship?
      friendship.destroy!
    end
  end

  protected

  def update_friendship
    friendship = Friendship.find(params[:friendship_id])
    if friendship.present?
      yield friendship if block_given?
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :not_found
    end
  end

  def render_records(friends)
    render json: friends, only: [:id, :first_name, :last_name, :skill]
  end
end
