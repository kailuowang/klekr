FactoryBot.define do
  factory :collector, :class => Collector do
    user_id { FactoryBot.generate(:user_id) }
    auth_token { 'a_auth_token' }
    user_name { 'UnitTestuser' }
  end
end
