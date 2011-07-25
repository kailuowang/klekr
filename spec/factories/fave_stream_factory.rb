Factory.define :fave_stream, :class => FaveStream do |fs|
  fs.user_id { Factory.next(:user_id) }
  fs.username "a john king"
  fs.user_url "http://flickr.com/photos/a_john_king"
  fs.collecting true
end

