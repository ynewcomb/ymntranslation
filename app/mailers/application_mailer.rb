class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILGUN_USER']
  layout 'mailer'
end
