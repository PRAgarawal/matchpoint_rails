module DateHelper
  class DateHelper
    def self.today_cutoff
      return Time.now.in_time_zone('America/Chicago').beginning_of_day
    end
  end
end
