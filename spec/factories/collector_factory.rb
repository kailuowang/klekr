Factory.define :collector, :class => Collector do |c|
  c.user_id { Factory.next(:user_id) }
  c.auth_token 'a_auth_token'
  c.user_name 'UnitTestuser'
end
