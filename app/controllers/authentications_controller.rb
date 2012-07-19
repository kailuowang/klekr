class AuthenticationsController < ApplicationController

  #GET validate
  def validate
    verifier = params[:oauth_verifier]
    token = session[:oauth_token]
    flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verifier)
    login = flickr.test.login
    collector = ::Collector.find_or_create_by_auth(user: login,
                                                   access_token: flickr.access_token,
                                                   access_secret: flickr.access_secret )
    if(params[:remember_me] == 'true')
      cookies.permanent.signed["collector_id"] = collector.id
    end

    collector.update_attribute(:last_login, DateTime.now)
    session[:collector_id] = collector.id
    self.current_collector = collector
    redirect_to_stored
  end

  #Get
  def show
    @show_detail = params[:show_detail].present?
    if current_collector && !@show_detail
      redirect_to slideshow_path
    else
      @auth_url = login_authentications_path
      @disable_navigation = true
      @redirected_to_login = redirected_for_login
    end
  end

  #login
  def login
    token = flickr.get_request_token(oauth_callback: oauth_callback_url(params[:remember_me]))
    session[:oauth_token] = token
    redirect_to flickr.get_authorize_url(token['oauth_token'], :perms => 'write')
  end


  #delete
  def destroy
    @disable_navigation = true
    reset_session
    cookies.permanent.signed["collector_id"] = nil
    redirect_to '/'
  end

  private
  def oauth_callback_url(remember_me)
    validate_authentications_url remember_me: remember_me
  end

end