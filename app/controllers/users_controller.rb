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

  def add_friend
    authorize User, :create_friendship?
    friend_finder = params[:friend_finder]

    # `friend_finder` will be either the friend's email, friend code, or ID
    friend = User.find_by(email: friend_finder.downcase)
    friend = User.find_by(invite_code: friend_finder.upcase) if friend.nil?
    friend = User.find_by(id: friend_finder) if friend.nil?

    if friend.nil?
      render json: {error: { detail: "Unable to find that user" }},
             status: :not_found
    else
      existing = Friendship.friendship_for_friend(friend.id, current_user.id)

      if existing.nil?
        Friendship.create!(user_id: current_user.id, friend_id: friend.id)
        FriendRequestMailer.request_received(friend, current_user).deliver_later
        render nothing: true, status: :ok
      else
        # Friendship already exists
        render nothing: true, status: :no_content
      end
    end
  end

  def invite_friend
    authorize User, :invite_friend?
    email = params[:email]
    if email.match(VALID_EMAIL_REGEX).nil?
      render json: {error: { detail: "Invalid email address." }},
             status: :bad_request
      return
    end
    new_user = User.new(email: email)
    new_user.invite!(current_user)
    render nothing: true, status: :ok
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
    friendship = Friendship.friendship_for_friend(params[:friend_id], current_user.id)
    current_user.friendship_to_authorize = friendship
    yield friendship if block_given?
    if friendship.present?
      render nothing: true, status: :no_content
    else
      render json: {error: { detail: "Friend not found" }}, status: :not_found
    end
  end

  def render_records(friends)
    render json: friends, only: [:id, :first_name, :last_name, :skill]
  end
end
