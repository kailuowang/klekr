class AdminMailer < ActionMailer::Base
  default from: "appserver@klekr.com"
  AdminEmail = "admin@klekr.com"

  def regular_report(subject, msg)
    @msg = msg
    email = mail(:to => AdminMailer::AdminEmail, :subject => subject).deliver
  end

end
