Factory.define :picture, :class => Picture do |p|
  secret = '5458393900'
  p.secret secret
  p.title 'a picture created by factory girl'
  p.url "http://farm6.static.flickr.com/5292/#{secret}_fcfb681a66_b.jpg"
  p.ref_url "http://www.flickr.com/photos/71017905@N00/#{secret}"
  p.date_upload  DateTime.new(2010, 1,31)
end