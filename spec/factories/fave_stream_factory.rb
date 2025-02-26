FactoryBot.define do
  factory :fave_stream, :class => FaveStream do
    user_id { FactoryBot.generate(:user_id) }
    username { "E.H. Gombrich" }
    collecting { true }
    association :collector, factory: :collector, last_login: Date.today
  end
end

