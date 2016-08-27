class FriendshipsController < RestfulController
  def render_records(friendships)
    render json: friendships, only: [:id, :is_confirmed], include: [
        friend: {only: [:id, :first_name, :last_name, :skill]}]
  end
end
