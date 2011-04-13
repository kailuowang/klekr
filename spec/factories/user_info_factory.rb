Factory.sequence :user_info do |n|
  FlickRaw::Response.new({"id"    =>  "#{n}",
                          "username" => "aTestUser",
                          "photosurl" => "http://flickr.com/photos/12131" }, "people")
end