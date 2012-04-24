FactoryGirl.define do
  factory :fave_stream, :class => FaveStream do |fs|
    fs.user_id {  FactoryGirl.generate(:user_id) }
    fs.username "E.H. Gombrich"
    fs.collecting true
    fs.collector {FactoryGirl.create(:collector, last_login: Date.today )}
  end
end

