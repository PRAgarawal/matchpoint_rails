class MatchMailer < ApplicationMailer
  include DateHelper

  def daily_digest(user)
    User.current_user = user
    @my_matches = user.matches.where('matches.match_date >= ?', Time.now).order(match_date: :asc).to_a

    #find my matches for user in the next 24 hours and use for trigger to remind user
    @my_matches24 = user.matches.where(match_date: Time.now..(Time.now + 1.days)).order(match_date: :asc).to_a
    @friend_matches = Match.new_from_friends.to_a
    @court_matches = Match.new_on_courts
                         .where.not(matches: { id: @friend_matches.pluck(:id) })
                         .to_a

    headers['X-SMTPAPI'] = '{"asm_group_id": 1911}'

    if @friend_matches.count > 0 || @court_matches.count > 0 || @my_matches24.count > 0
      @first_name = user.first_name
      mail(to: user.email, subject: "New Matches - #{Date.today.strftime('%a %b %-d, %Y')}")
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

    headers['X-SMTPAPI'] = '{"asm_group_id": 1915}'

    mail(to: to_user.email, subject: subject_match_update(match))
  end

  def score_submitted(to_user, user, match)
    @match = match
    @friend = user
    @to_user_name = to_user.first_name

    headers['X-SMTPAPI'] = '{"asm_group_id": 1915}'

    mail(to: to_user.email, subject: subject_match_update(match))
  end
end
