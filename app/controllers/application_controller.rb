class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    return true unless Settings.authentication
    return true if session[:collector_id]
    session[:return_to]= request.path

    redirect_to FlickRaw.auth_url :perms => 'write'
    false
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to] = nil
      redirect_to(return_to)
    else
      redirect_to('/')
    end
  end

  def current_collector
    if Settings.authentication
      Collector.find_by_id(session[:collector_id])
    else
      Collector.find_by_user_id(Collectr::FLICKR_USER_ID)
    end
  end
end
