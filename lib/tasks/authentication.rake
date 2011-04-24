desc "get authentication token for development purpose"
task :authenticate => :environment do
  require 'flickraw'

  frob = flickr.auth.getFrob
  auth_url = FlickRaw.auth_url :frob => frob, :perms => 'write'

  puts "Open this url in your process to complete the authication process : #{auth_url}"
  puts "Press Enter when you are finished."
  STDIN.getc

  begin
    auth = flickr.auth.getToken :frob => frob
    login = flickr.test.login
    puts "You are now authenticated as #{login.username} with token '#{auth.token}', paste the token into your flickr.yml"
  rescue FlickRaw::FailedResponse => e
    puts "Authentication failed : #{e.msg}"
  end

end