class CookieSettingsController < ApplicationController
  def update
    respond_to do |format|
      params.each do |k, v|
        cookies[k] = {value: v, :expires => 1.year.from_now}
      end

      format.html { redirect_to(:back) }
      format.xml { head :ok }
    end
  end

end
