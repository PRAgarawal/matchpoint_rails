desc 'Set a unique, random invite code for all existing users'
task :initialize_invite_codes => :environment do
  User.all.each do |user|
    # Random, 5-character, alphanumeric string
    user.update_attributes!(invite_code: rand(36**14).to_s(36)[0..4].upcase,
                            invited_by_code: 'BOGUS')
  end
end
