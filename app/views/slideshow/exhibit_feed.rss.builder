xml.instruct! :xml, :version => "1.0", standalone: "yes"
xml.rss version: "2.0", 'xmlns:media' => "http://search.yahoo.com/mrss/" do
  xml.channel do
    xml.title "klekr.com - editors choice photos"
    xml.description "Discover photos of your own taste"
    xml.link "http://klekr.com/slideshow/exhibit?collector_id=#{@collector.id}&order_by=date"
    xml.pubDate DateTime.now.to_s(:rfc822)
    xml.lastBuildDate @pictures.first.faved_at.to_datetime.to_s(:rfc822)
    xml.managingEditor 'kailuo.wang@gmail.com'
    for picture in @pictures
      xml.item do
        xml.title picture.display_title
        xml.link picture_url(picture, @exhibit_url)
        xml.description picture.description
        xml.pubDate picture.faved_at.to_datetime.to_s(:rfc822)
        xml.guid picture_url(picture, @exhibit_url)
        xml.media :content, url: picture.large_url, type: "image/jpeg"
        xml.media :credit, role: "photographer" do
          xml.text! picture.owner_name
        end
      end
    end
  end
end
