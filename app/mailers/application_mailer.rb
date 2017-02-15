class ApplicationMailer < ActionMailer::Base
  default from: '"Match Point" <postmaster@mail.matchpoint.us>'
  layout 'mailer'

  def subject_match_update(match)
    return "Update to your #{match.is_singles ? 'singles' : 'doubles'} match on #{match.formatted_match_date}"
  end
end
