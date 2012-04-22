module Collectr
  class PictureRepo
    include Collectr::Flickr

    def initialize(collector)
      @collector = collector
    end

    def find(string_id)
      if Picture.is_flickr_id?(string_id)
        find_by_flickr_id(string_id)
      else
        find_by_db_id(string_id)
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

    def new_pictures(opts = {})
      default_opts = {limit: 10, offset: 0}
      opts.reverse_merge!(default_opts)
      scope = Picture.collected_by(@collector).
                      limit(opts[:limit].to_i).
                      offset(opts[:offset].to_i).
                      includes(:flickr_streams, :collector)

      if Rails.env.production?
        scope = scope.from("`pictures` USE INDEX (new_pictures_index)")
      end

      scope = unless opts[:viewed]
        scope.unviewed.desc
      else
        scope.order('created_at DESC')
      end

      if opts[:type].present?
        scope.where("#{::FlickrStream.table_name}.type = ?", opts[:type])
      else
        scope
      end
    end

    private

    def find_by_db_id(string_id)
      pic = Picture.find(string_id)
      if(pic.collector == @collector)
        pic
      else
        find_or_initialize_from_pic_info(pic.pic_info)
      end
    end

    def find_or_initialize_from_pic_info(pic_info)
      url = get_photopage_url(pic_info)
      Picture.where(collector_id: @collector, url: url).includes(:flickr_streams).first ||
        Picture.new.tap do |picture|
          picture.url = url
          picture.pic_info = pic_info
          picture.description = pic_info.to_hash.delete('description')
          picture.collector = @collector
        end
    end

    def get_photopage_url(pic_info)
      begin
        FlickRaw.url_photopage(pic_info)
      rescue #todo fix this after upgrading flickraw
        pic_info.urls[0]["_content"].to_s
      end
    end

    def find_by_flickr_id(string_id)
      fid, secret = string_id.split('_')
      pic_info = flickr.photos.getInfo(photo_id: fid, secret: secret)
      find_or_initialize_from_pic_info(pic_info)
    end

  end
end