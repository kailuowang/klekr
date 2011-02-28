module PicturesHelper
  def display_title(pic)
    pic.title.present? ? pic.title : "untitled"
  end

  def next_picture_path(pic)
    pic.previous ? picture_path(pic.previous.id) : "#"
  end
end
