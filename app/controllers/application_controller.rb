class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate

    unless Settings.authentication
      self.current_collector = ::Collector.find_by_user_id(Collectr::FlickrUserId)
      return true
    end

    if session[:collector_id]
      self.current_collector = ::Collector.find_by_id(session[:collector_id])
      return true
    end

    session[:return_to]= request.path

    redirect_to authentications_path
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
    @current_collector = collector
  end
end
