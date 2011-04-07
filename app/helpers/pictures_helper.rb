module PicturesHelper
  def display_title(pic)
    pic.title.present? ? pic.title : "untitled"
  end


  def window_size_px
    case window_size
      when :large
        '1024'
      when :medium
        '750'
    end
  end
end
