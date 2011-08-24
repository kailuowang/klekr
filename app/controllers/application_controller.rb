class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate

    if current_collector
      return true
    end

    unless authenticating
      self.current_collector = ::Collector.find_by_user_id(Collectr::FlickrUserId)
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
    @current_collector ||= ::Collector.find_by_id(session[:collector_id]) if session[:collector_id]
  end

  def current_collector= collector
    session[:collector_id] = collector.try(:id)
    @current_collector = collector
  end

  def render_json(data)
    respond_to do |f|
      f.js { render :json => data }
    end
  end

  def js_ok
    respond_to do |format|
      format.js  { render :json => {} }
    end
  end

  private

  def authenticating
    Settings.authentication
  end

end
