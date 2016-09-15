class MatchMailer < ApplicationMailer
  def daily_digest(user)
    User.current_user = user
    @my_matches = user.matches.where('matches.match_date >= CURRENT_DATE')
    @friend_matches = Match.available_from_friends
    @court_matches = Match.available_on_courts
    @date = Date.today.strftime('%b %-d, %Y')

    if @my_matches.first.present? || @friend_matches.first.present? || @court_matches.first.present?
      mail(to: user.email, subject: "Your Daily Summary - #{@date}")
    end
  end
end
