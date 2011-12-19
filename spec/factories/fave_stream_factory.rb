Factory.define :fave_stream, :class => FaveStream do |fs|
  fs.user_id { Factory.next(:user_id) }
  fs.username "E.H. Gombrich"
  fs.collecting true
  fs.collector {Factory(:collector, last_login: Date.today )}
end

