class Collector < ActiveRecord::Base
  has_many :flickr_streams
  has_many :pictures

  def self.find_or_create_by_auth(auth)
    user = auth.user
    user_id = user.nsid
    existing_collector = find_by_user_id(user_id)
    existing_collector ? existing_collector :
            create(user_id: user_id, auth_token: auth.token, user_name: user.username, full_name: user.fullname)
  end
end