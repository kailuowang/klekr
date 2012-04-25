class AdminMailer < ActionMailer::Base
  default from: "appserver@klekr.com"
  AdminEmail = "admin@klekr.com"

  def regular_report(subject, msg)
    @msg = msg
    mail(:to => AdminMailer::AdminEmail, :subject => "#{Rails.env}: #{subject}").deliver
  end

end
