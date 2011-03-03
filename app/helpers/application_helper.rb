module ApplicationHelper
  def window_size
    cookies[:window_size].try(:to_sym)
  end
end
