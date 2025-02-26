
FactoryBot.define do

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

  factory :picture, :class => Picture do
    transient do
      pic_info { FactoryBot.generate(:pic_info) }
    end

    title { pic_info.title }
    description { pic_info.description }
    url { FlickRaw.url_photopage(pic_info) }
    pic_info_dump { pic_info.marshal_dump }
    date_upload { Time.at(pic_info.dateupload.to_i).to_datetime }
    owner_name { 'Hillary Clinton' }
    viewed { false }
    stream_rating { 0 }
    association :collector
  end
end