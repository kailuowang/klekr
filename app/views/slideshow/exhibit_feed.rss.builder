xml.instruct! :xml, :version => "1.0", standalone: "yes"
xml.feed 'xmlns'=>"http://www.w3.org/2005/Atom" do
    xml.title "klekr.com - editors choice photos"
    xml.subtitle "Discover photos of your own taste"
    xml.id "tag:klekr.com,2005:/slideshow/exhibit?collector_id=#{@collector.id}"
    xml.updated DateTime.now.to_s(:rfc3339)
    xml.link href: @exhibit_url, rel: 'alternate', type: "text/html"
    xml.link href: "#{exhibit_feed_slideshow_url(@exhibit_params.merge(format: :rss))}", rel: "self"
    for picture in @pictures
      xml.entry do
        xml.id picture_url(picture, @exhibit_url)
        xml.title picture.title.present? ? picture.title : 'untitled'
        xml.published picture.faved_at.to_datetime.to_s(:rfc3339)
        xml.updated picture.faved_at.to_datetime.to_s(:rfc3339)
        xml.link href: picture_url(picture, @exhibit_url), rel: "alternate", type: "text/html"
        xml.link rel: 'enclosure', href: picture.large_url, type: "image/jpeg"
        xml.content type: "html" do
          xml.text! <<CONTENT
            #{picture.description.present? ? picture.description : "There is no description."}
            <br /> <br />All photos copyrighted © by their respective owners
            <br /><br /> <a href='#{picture_url(picture, @exhibit_url)}'>View on klekr</a>
CONTENT
        end
        xml.author do
          xml.name picture.owner_name
          xml.uri "http://flickr.com/photos/#{picture.owner_id}"
        end

      end
    end
end
