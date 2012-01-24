module Collectr
  class FaveImporter
    include Collectr::Flickr

    attr_reader :collector, :faved_before

    def initialize(collector, faved_before)
      @collector = collector
      @faved_before = faved_before
    end

    def import(num)
      pictures = fave_stream.get_pictures(num, 1, nil, @faved_before)
      update_pictures_faved_at(pictures) if (pictures.present?)
      pictures
    end

    private

    def fave_stream
      @fave_stream ||= FlickrStream.build_type(user_id: @collector.user_id,
                                               username: @collector.user_name,
                                               collector: @collector,
                                               type: 'FaveStream')
    end

    def update_pictures_faved_at(pictures)
      earlest_date = collector_faved_at(pictures.last.pic_info)
      pictures.each_with_index do |pic, index|
        offset = pictures.size - index - 1 #to retain the original sequence of fave without querying for fave date for all pictures
        pic.update_attributes(
          faved_at: Time.at(earlest_date + offset).to_datetime,
          rating: 1,
          viewed: true
        )
      end
    end

    def collector_faved_at(pic)
      fave_info = find_fave_info_by_page(pic, 1)
      if(fave_info)
        fave_info.favedate.to_i
      else
        Rails.logger.error("can't find fave date for pic #{pic.id} and collector #{collector.id}" )
        pic.dateupload.to_i
      end
    end

    def find_fave_info_by_page(pic, page = 1)
      faves =
        begin
          flickr.photos.getFavorites(photo_id: pic.id, secret: pic.secret, per_page: 50, page: page)
        rescue FlickRaw::FailedResponse => e;
          Rails.logger.error(e.inspect)
          nil
        end
      if faves && faves.person.size > 0
        faves.person.find{ |p| p.nsid == @collector.user_id } || find_fave_info_by_page(pic, page + 1)
      end
    end

  end
end