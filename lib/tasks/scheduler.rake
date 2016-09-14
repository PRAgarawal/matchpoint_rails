# Send a daily digest email to all users telling them about matches they have joined and those
# they have available
desc 'Task called by Heroku. Should run every day at 2PM CST.'
task send_daily_digests: :environment do
  User.all.each do |user|
    MatchMailer.daily_digest(user).deliver_later
  end
end
