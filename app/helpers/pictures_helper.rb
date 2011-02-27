module PicturesHelper
  def display_title(pic)
    pic.title.present? ? pic.title : "untitled"
  end
end
