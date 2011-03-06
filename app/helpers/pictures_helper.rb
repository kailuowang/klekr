module PicturesHelper
  def display_title(pic)
    pic.title.present? ? pic.title : "untitled"
  end

  def next_picture_path(pic)
    next_pic = pic.next_new_pictures(1).first
    next_pic ? picture_path(next_pic) : slide_show_pictures_path
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
