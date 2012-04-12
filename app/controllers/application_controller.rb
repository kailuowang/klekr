class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :navigation_setup
  before_filter :check_authentication_requested

  def check_authentication_requested
    if params[:do_login] == 'true'
      authenticate
    end
  end

  def authenticate

    if current_collector
      return true
    end

    unless authenticating
      self.current_collector = development_collector
      return true
    end

    unless ajax_url?(request.url)
      set_return_url(request.url)
    end

    redirect_to authentications_path
    false
  end

  def set_return_url url
    session[:return_to]= url
  end

  def redirect_to_stored
    return_to = '/slideshow'
    if session[:return_to].present?
      unless ajax_url?(session[:return_to])
        return_to = session[:return_to]
      end
      session[:return_to] = nil
    end

    redirect_to return_to
  end

  def redirected_for_login
    session[:return_to].present? && current_collector.blank?
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

  def ajax_url? url
    url =~ /\.json$/
  end

  def authenticating
    Settings.authentication
  end

  def navigation_setup
    @navigation_options = [{name: 'My Sources', path: flickr_streams_path},
                           {name: 'My Faves', path: faves_slideshow_path},
                           {name: 'My Stream', path:  slideshow_path} ]
  end

  def development_collector
    params[:as_test_collector].present? ?
      ::Collector.find_or_create(user_id: Collectr::TestFlickrUserId,
        user_name: Collectr::TestFlickrUserName,
        auth_token: Collectr::TestFlickrAuthToken) :
      ::Collector.find_or_create(user_id: Collectr::DevFlickrUserId,
        user_name: Collectr::DevFlickrUserName,
        auth_token: Collectr::DevFlickrAuthToken)
  end


end
