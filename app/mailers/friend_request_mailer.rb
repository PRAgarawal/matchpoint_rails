class FriendRequestMailer < ApplicationMailer
  # user is the user receiving the request, friend is the user sending the request
  def request_received(user, friend)
    @user_name = user.first_name
    @friend_name = "#{friend.first_name} #{friend.last_name}"
    @friend_first_name = friend.first_name

    mail(to: user.email, subject: "#{@friend_name} wants to be your friend!")
  end
end
