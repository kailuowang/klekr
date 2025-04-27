FactoryBot.define do
  factory :upload_stream, :class => UploadStream do
    user_id { FactoryBot.generate(:user_id) }
    username { "Stephen Shore" }
    collecting { true }
    association :collector, factory: :collector, last_login: Date.today
  end
end

