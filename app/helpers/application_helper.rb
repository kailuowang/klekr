module ApplicationHelper
  def picture_show_size
    cookies[:picture_show_size] || 'medium'
  end
end
