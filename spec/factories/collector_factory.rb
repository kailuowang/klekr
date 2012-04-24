FactoryGirl.define do
  factory :collector, :class => Collector do |c|
    c.user_id {  FactoryGirl.generate(:user_id) }
    c.auth_token 'a_auth_token'
    c.user_name 'UnitTestuser'
  end
end
