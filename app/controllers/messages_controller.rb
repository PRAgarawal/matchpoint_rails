class MessagesController < RestfulController
  def index_scope(scope)
    chat = Chat.find_by(match_id: params[:match_id])
    raise Pundit::NotAuthorizedError if !authorize_chat(chat)
    return chat.messages.order(created_at: :desc)
  end

  def create
    super { |message|
      message.user_id = current_user.id
    }
  end

  protected

  def render_records(messages)
    render json: messages, include: [
        user: {only: [:first_name, :last_name]}]
  end

  private

  # returns true if the user has permissions to view messages on this chat
  # TODO: see if this can be done directly with pundit
  def authorize_chat(chat)
    chat.users.include?(current_user)
  end
end
