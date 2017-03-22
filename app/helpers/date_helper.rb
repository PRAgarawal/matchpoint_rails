module DateHelper
  def self.timezone(user)
    return user.is_dfw ? 'America/Chicago' : 'America/Los_Angeles'
  end

  def self.today_cutoff(user)
    return Time.now.in_time_zone(self.timezone(user)).beginning_of_day
  end
end
