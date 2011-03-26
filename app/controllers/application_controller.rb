class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    return true unless Settings.authentication
    return true if session[:user]

    flash[:warning]='Please login to continue'
    session[:return_to]= request.path
    redirect_to authentications_path
    false
  end

   def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to(return_to)
    else
      redirect_to('/')
    end
  end

end
