module DateHelper
  class DateHelper
    def self.timezone
      return User.current_user.is_dfw ? 'America/Chicago' : 'America/Los_Angeles'
    end

    def self.today_cutoff
      return Time.now.in_time_zone(self.timezone).beginning_of_day
    end
  end
end
