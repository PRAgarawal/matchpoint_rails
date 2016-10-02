class MatchMailer < ApplicationMailer
  def daily_digest(user)
    User.current_user = user
    @my_matches = user.matches.where('matches.match_date >= CURRENT_DATE')
    @friend_matches = Match.available_from_friends
    @court_matches = Match.available_on_courts
    @date = Date.today.strftime('%b %-d, %Y')

    if @my_matches.first.present? || @friend_matches.first.present? || @court_matches.first.present?
      @first_name = user.first_name
      mail(to: user.email, subject: "Your Daily Summary - #{@date}")
    end
  end

  def self.joined_match(user, match)
    self.joined_left_setup(user, match, 'joined')
  end

  def self.left_match(user, match)
    self.joined_left_setup(user, match, 'left')
  end

  # Notify each user on a match that someone joined or left
  def self.joined_left_setup(user, match, joined_left = 'joined')
    match.users.each { |to_user|
      MatchMailer.joined_left_match(to_user, user, match, joined_left).deliver_later if user.id != to_user.id
    }
  end

  def joined_left_match(to_user, user, match, joined_left = 'joined')
    @joined_left = joined_left
    @match = match
    @friend = user
    @to_user_name = to_user.first_name
    @match_type = match.is_singles ? 'singles' : 'doubles'
    mail(to: to_user.email, subject: "#{user.first_name} has #{joined_left} your #{@match_type} match on #{match.match_date.strftime('%b %-d, %Y')}")
  end
end
