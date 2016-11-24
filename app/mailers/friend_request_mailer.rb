class FriendRequestMailer < ApplicationMailer
  # user is the user receiving the request, friend is the user sending the request
  def request_received(user, friend)
    @user_name = user.first_name
    @friend_name = "#{friend.first_name} #{friend.last_name}"
    @friend_first_name = friend.first_name

    mail(to: user.email, subject: "#{@friend_name} wants to be your friend on Match Point")
  end

  def request_accepted(user, friend)
    @user_name = user.first_name
    @friend_name = "#{friend.first_name} #{friend.last_name}"
    @friend_first_name = friend.first_name
    @is_from_inviter = friend.invited_by_id == user.id
    subject = @is_from_inviter ?
        "#{@friend_name} has accepted your invitation to join Match Point" :
        "#{@friend_name} has accepted your friend request on Match Point"

    mail(to: user.email, subject: subject)
  end
end
