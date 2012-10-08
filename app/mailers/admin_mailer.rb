class AdminMailer < ActionMailer::Base
  default from: "appserver@klekr.com"
  AdminEmail = "admin@klekr.com"

  def regular_report(subject, msg)
    @msg = msg
    report(subject)
  end

  def report(subject)
    mail(:to => AdminMailer::AdminEmail, :subject => "#{Rails.env}: #{subject}").deliver
  end

  def error_report(exception, title = "An exception occurred.")
    @exception = exception
    @title = title
    report("DON'T PANIC!")
  end

end
