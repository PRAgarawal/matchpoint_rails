class MatchMailer < ApplicationMailer
  def daily_digest(user)
    User.current_user = user
    @my_matches = user.matches.where('matches.match_date >= CURRENT_DATE')
    @friend_matches = Match.available_from_friends
    @court_matches = Match.available_on_courts


    if @my_matches.first.present? || @friend_matches.first.present? || @court_matches.first.present?
      mail(to: user.email, subject: "Your Daily Summary - #{@date}")
    end
  end

  def self.joined_match(user, match)
    self.joined_left_setup(user, match, 'joined')
  end

  def self.left_match(user, match)
    self.joined_left_setup(user, match, 'left')
  end

  def self.joined_left_setup(user, match, joined_left = 'joined')
    emails = match.users.pluck(:email)
    emails.delete(user.email)
    emails.each { |email|
      MatchMailer.joined_left_match(email, user, match, joined_left).deliver_later
    }
  end

  def joined_left_match(email, user, match, joined_left = 'joined')
    @joined_left = joined_left
    @match = match
    @user = user
    mail(to: email, subject: "#{user.first_name} has #{joined_left} your match on #{match.match_date.strftime('%b %-d, %Y')}")
  end
end
