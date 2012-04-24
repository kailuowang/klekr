
FactoryGirl.define do

  sequence :pic_info do |n|
    FlickRaw::Response.new({"id"    =>  "#{n}",
                            "owner" =>  '23242325@N00',
                            "secret"=>  "dfd91ef#{n * 17}",
                            "server"=>  "5162",
                            "farm"  =>  6,
                            "title" =>  "test picture num#{n}",
                            "ispublic"  =>  1,
                            "isfriend"  =>  0,
                            "isfamily"  =>  0,
                            'description' => 'this picture is taken in some really weird place',
                            "ownername"=>  'John Kim',
                            "dateupload"=>"1294841334"}, "photo")
  end

  factory :picture, :class => Picture do |p|
    pic_info =  FactoryGirl.generate(:pic_info)
    p.title pic_info.title
    p.description pic_info.description
    p.url FlickRaw.url_photopage(pic_info)
    p.pic_info_dump pic_info.marshal_dump
    p.date_upload  Time.at(pic_info.dateupload.to_i).to_datetime
    p.owner_name 'Hillary Clinton'
    p.viewed false
    p.stream_rating 0
    p.collector_id { FactoryGirl.create(:collector).id }
  end



end