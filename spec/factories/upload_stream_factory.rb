Factory.define :upload_stream, :class => UploadStream do |fs|
  fs.user_id { Factory.next(:user_id) }
  fs.username "Stephen Shore"
  fs.user_url "http://flickr.com/photos/stephen"
  fs.collecting true
end

