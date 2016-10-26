class MatchMailer < ApplicationMailer
  include DateHelper

  def daily_digest(user)
    User.current_user = user
    @my_matches = user.matches.where('matches.match_date >= ?', DateHelper.today_cutoff).order(match_date: :asc).to_a
    @friend_matches = Match.available_from_friends.to_a
    @court_matches = Match.available_on_courts
                         .where.not(matches: { id: @friend_matches.pluck(:id) })
                         .to_a

    if @my_matches.count > 0 || @friend_matches.count > 0 || @court_matches.count > 0
      @first_name = user.first_name
      mail(to: user.email, subject: "Your Daily Summary - #{Date.today.strftime('%a %b %-d, %Y')}")
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
    mail(to: to_user.email, subject: "Update to your Singles match on #{match.formatted_match_date}")
  end
end
