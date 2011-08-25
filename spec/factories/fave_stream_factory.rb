Factory.define :fave_stream, :class => FaveStream do |fs|
  fs.user_id { Factory.next(:user_id) }
  fs.username "E.H. Gombrich"
  fs.user_url "http://flickr.com/photos/gombrich"
  fs.collecting true
end

