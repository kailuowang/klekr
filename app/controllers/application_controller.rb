class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :navigation_setup

  def authenticate

    if current_collector
      return true
    end

    unless authenticating
      self.current_collector = ::Collector.find_or_create(user_id: Collectr::DevFlickrUserId,
                                                          user_name: Collectr::DevFlickrUserName,
                                                          auth_token: Collectr::DevFlickrAuthToken)
      return true
    end

    session[:return_to]= request.url

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
      f.json { render :json => data }
    end
  end

  def js_ok
    render_json(['success'])
  end

  private

  def authenticating
    Settings.authentication
  end

  def navigation_setup
    @navigation_options = [{name: 'My Sources', path: flickr_streams_path},
                           {name: 'My Collection', path: faves_slideshow_path},
                           {name: 'My Stream', path:  slideshow_path} ]
  end
end
