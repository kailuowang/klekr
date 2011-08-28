Factory.define :upload_stream, :class => UploadStream do |fs|
  fs.user_id { Factory.next(:user_id) }
  fs.username "Stephen Shore"
  fs.collecting true
end

