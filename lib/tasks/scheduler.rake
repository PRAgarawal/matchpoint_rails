# Send a daily digest email to all users telling them about matches they have joined and those
# they have available
desc 'Task called by Heroku to send daily email updates. Should run every day at 2PM CST.'
task send_daily_digests: :environment do
  User.all.each do |user|
    MatchMailer.daily_digest(user).deliver_now
  end
end

# Since the user score (right now just number of full matches) is a complicated query,
# it will be too expensive to do on demand, so we need to do it in a daily task.
desc 'Task called by Heroku to update users\' scores. Should run every day at 2AM CST.'
task update_user_scores: :environment do
  User.update_scores
end
