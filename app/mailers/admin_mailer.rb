class AdminMailer < ActionMailer::Base
  default from: "appserver@klekr.com"
  AdminEmail = "admin@klekr.com"

  def error_report(error_msg, recipient = AdminMailler::AdminEmail)
    @error_msg = error_msg
    mail(:to => recipient, :subject => "Error occurred on klekr").deliver
  end

  def regular_report(subject, msg)
    @msg = msg
    mail(:to => AdminMailer::AdminEmail, :subject => subject).deliver
  end
end
