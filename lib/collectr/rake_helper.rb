module Collectr::RakeHelper

  def output(msg)
    if(Rails.env == 'production')
      puts(DateTime.now.to_s + ": " + msg)
    else
      Rails.logger.info(msg)
    end
  end

  def with_error_report
    begin
      yield
    rescue  => e
      Rails.logger.error(e)
      AdminMailer.error_report(e)
    end
  end
end