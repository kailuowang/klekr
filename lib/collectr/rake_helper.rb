module Collectr::RakeHelper

  def output(msg)
    if(Rails.env == :production)
      puts(DateTime.now.to_s + ": " + msg)
    else
      Rails.logger.info(msg)
    end
  end
end