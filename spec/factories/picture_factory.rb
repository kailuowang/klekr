Factory.define :picture, :class => Picture do |p|
  pic_info = Factory.next(:pic_info)
  p.title pic_info.title
  p.url FlickRaw.url_photopage(pic_info)
  p.pic_info_dump pic_info.marshal_dump
  p.date_upload  Time.at(pic_info.dateupload.to_i).to_datetime
  p.viewed false
end