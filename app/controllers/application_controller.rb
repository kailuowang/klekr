class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required

    unless Settings.authentication
      current_collector = ::Collector.find_by_user_id(Collectr::FLICKR_USER_ID)
      return true
    end

    if session[:collector_id]
      current_collector = ::Collector.find_by_id(session[:collector_id])
    end

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
    Thread.current[:current_collector]
  end

  def current_collector= collector
    session[:collector_id] = collector.try(:id)
    Thread.current[:current_collector] = collector
  end
end
