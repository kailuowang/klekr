Factory.sequence :pic_info do |n|
  FlickRaw::Response.new({"id"    =>  "#{n}",
                          "owner" =>  '23242325@N00',
                          "secret"=>  "dfd91ef806",
                          "server"=>  "5162",
                          "farm"  =>  6,
                          "title" =>  "a test picture created by factory",
                          "ispublic"  =>  1,
                          "isfriend"  =>  0,
                          "isfamily"  =>  0,
                          "ownername"=>  'John Kim',
                          "dateupload"=>"1294841334",
                          "date_faved"=>"1298678009"}, "photo")
end

Factory.define :picture, :class => Picture do |p|
  pic_info = Factory.next(:pic_info)
  p.title pic_info.title
  p.url FlickRaw.url_photopage(pic_info)
  p.pic_info_dump pic_info.marshal_dump
  p.date_upload  Time.at(pic_info.dateupload.to_i).to_datetime
  p.owner_name 'Hillary Clinton'
  p.viewed false
  p.stream_rating 0
  p.collector_id { Factory(:collector).id }
end