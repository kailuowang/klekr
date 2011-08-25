module Collectr
  class PictureRepo
    include Collectr::Flickr

    def initialize(collector)
      @collector = collector
    end

    def find(string_id)
      if is_flickr_id?(string_id)
        find_by_flickr_id(string_id)
      else
        Picture.find(string_id)
      end
    end

    def build(pic_info)
      find_or_initialize_from_pic_info(pic_info)
    end

    def create_from_sync(pic_info, stream)
      picture = build(pic_info)
      already_synced = !picture.new_record? && stream.synced_with?(picture)
      picture.synced_by(stream) unless already_synced
      return picture, !already_synced
    end


    def new_pictures(*exclude_ids)
      scope = Picture.collected_by(@collector).desc.unviewed.includes(:flickr_streams)
      pictures = Picture.arel_table
      if exclude_ids.present?
        scope = scope.where(pictures[:id].not_in(exclude_ids))
      end
      scope
    end

    private

    def find_or_initialize_from_pic_info(pic_info)
      url = FlickRaw.url_photopage(pic_info)
      Picture.where(collector_id: @collector, url: url).includes(:flickr_streams).first ||
        Picture.new.tap do |picture|
          picture.url = url
          picture.title = pic_info.title
          picture.date_upload = get_upload_date(pic_info)
          picture.owner_name = pic_info['ownername'] || pic_info['owner']['username']
          picture.pic_info_dump = pic_info.marshal_dump
          picture.collector = @collector
        end
    end

    def is_flickr_id?(string_id)
      string_id.to_s.include?('_')
    end

    def get_upload_date(pic_info)
      rawdate = pic_info['dateupload'] || pic_info['dateuploaded']
      Time.at(rawdate.to_i).to_datetime
    end

    def find_by_flickr_id(string_id)
      fid, secret = string_id.split('_')
      pic_info = flickr.photos.getInfo(photo_id: fid, secret: secret)
      find_or_initialize_from_pic_info(pic_info)
    end

  end
end