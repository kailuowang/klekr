class AuthenticationsController < ApplicationController

  #GET validate
  def validate
    auth = flickr.auth.getToken(frob: params[:frob])
    collector = ::Collector.find_or_create_by_auth(auth)
    collector.update_attribute(:last_login, DateTime.now)
    session[:collector_id] = collector.id
    self.current_collector = collector
    redirect_to_stored
  end

  #Get
  def show
    @disable_navigation = true
    @redirected_to_login = redirected_for_login
    frob = flickr.auth.getFrob
    @auth_url = FlickRaw.auth_url(perms: 'write', frob: frob )
    @show_detail = params[:show_detail].present?
    @editor_choice_path = exhibit_slideshow_path(collector_id: Collectr::Editor.new.ensure_editor_collector.id, rating: 2, order_by: 'date' )
    if current_collector && !@show_detail
      redirect_to slideshow_path
    end
  end

  #delete
  def destroy
    @disable_navigation = true
    reset_session
    render 'bye'
  end

end