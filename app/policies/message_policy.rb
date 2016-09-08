class MessagePolicy < Struct.new(:user, :message)
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def permitted_attributes_for_create
    [:chat_id, :body]
  end

  def create?
    message.chat.users.include?(user) && (message.user_id == user.id)
  end
end
