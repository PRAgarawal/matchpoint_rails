class UsersController < RestfulController
  include RegexHelper

  # For rendering friends
  def index_scope(scope)
    requests = params[:requests]
    
    # return unconfirmed incoming friend requests, default to just returning confirmed friends
    if requests == "true"
      scope = current_user.incoming_friends
    end

    return scope
  end

  def create_friendship
    #TODO: add `friend_finder` to permitted params
    authorize User, :create_friendship?
    friend_finder = params[:friend_finder]

    # `friend_finder` will be either the friend's email or friend code
    user = User.find_by(email: friend_finder)
    user = User.find_by(invite_code: friend_finder) if user.nil?

    if user.nil?
      if friend_finder.present? && friend_finder.match(VALID_EMAIL_REGEX).nil?
        render json: {error: { detail: "Unable to find a user by that invite code" }},
               status: :not_found
      elsif friend_finder.match(VALID_EMAIL_REGEX).present?
        # TODO: The user entered an email that isn't yet on the system, so let's send them an invite
      end
    else
      existing = Friendship.where("(user_id = #{current_user.id} AND friend_id = #{user.id}) OR
                                    (user_id = #{user.id} AND friend_id = #{current_user.id})")
                     .first

      if existing.nil?
        Friendship.create!(user_id: current_user.id, friend_id: user.id)
        render nothing: true, status: :ok
      else
        # Friendship already exists
        render nothing: true, status: :no_content
      end
    end
  end

  def accept_friendship
    update_friendship do |friendship|
      authorize friendship.user, :accept_friendship?
      friendship.update_attributes!(is_confirmed: true) if friendship.present?
    end
  end

  def destroy_friendship
    update_friendship do |friendship|
      authorize User, :destroy_friendship?
      friendship.destroy! if friendship.present?
    end
  end

  protected

  def update_friendship
    friendship = Friendship.find_by(id: params[:friendship_id])
    current_user.friendship_to_authorize = friendship
    yield friendship if block_given?
    if friendship.present?
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :not_found
    end
  end

  def render_records(friends)
    render json: friends, only: [:id, :first_name, :last_name, :skill]
  end
end
