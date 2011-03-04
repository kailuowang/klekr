Factory.sequence :pic_info do |n|
  FlickRaw::Response.new({"id"=>"#{n}", "owner" => '23242325@N00', "secret"=>"dfd91ef806", "server"=>"5162", "farm"=>6, "title"=>"a test picture created by factory", "ispublic"=>1, "isfriend"=>0, "isfamily"=>0, "dateupload"=>"1294841334", "date_faved"=>"1298678009"}, "photo")
end