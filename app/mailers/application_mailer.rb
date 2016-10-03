class ApplicationMailer < ActionMailer::Base
  default from: '"Match Point" <postmaster@mail.matchpoint.us>'
  layout 'mailer'
end
