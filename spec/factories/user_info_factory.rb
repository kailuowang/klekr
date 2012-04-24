FactoryGirl.define do
  sequence :user_info do |n|
    FlickRaw::Response.new({"nsid"    =>  "#{n}",
                            "username" => "aTestUser",
                            "photosurl" => "http://flickr.com/photos/12131" }, "people")
  end

  sequence :user_id do |n|
    "45425#{n}@N00"
  end
end