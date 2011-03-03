module PicturesHelper
  def display_title(pic)
    pic.title.present? ? pic.title : "untitled"
  end

  def next_picture_path(pic)
    pic.previous ? picture_path(pic.previous.id) : "#"
  end

  def window_size_px
    case window_size
      when :large
        '1024'
      when :medium
        '750'
      else
        '750'
    end
  end
end
