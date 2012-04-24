FactoryGirl.define do
  factory :upload_stream, :class => UploadStream do |fs|
    fs.user_id {  FactoryGirl.generate(:user_id) }
    fs.username "Stephen Shore"
    fs.collecting true
  end
end

