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
        scope = scope.joins(:flickr_streams)
        scope.where("#{::FlickrStream.table_name}.type = ?", opts[:type])
      else
        scope
      end
    end

    # Make method public for testing
    def find_or_initialize_from_pic_info(pic_info)
      url = get_photopage_url(pic_info)
      Picture.where(collector_id: @collector, url: url).includes(:flickr_streams).first ||
        Picture.new.tap do |picture|
          picture.url = url
          picture.pic_info = pic_info
          # Handle description differently based on pic_info type
          if pic_info.respond_to?(:to_hash)
            picture.description = pic_info.to_hash.delete('description')
          elsif pic_info.respond_to?(:pic_info_dump) && pic_info.pic_info_dump.is_a?(Array) && pic_info.pic_info_dump.first.is_a?(Hash)
            picture.description = pic_info.pic_info_dump.first['description']
          end
          picture.collector = @collector
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

    def get_photopage_url(pic_info)
      begin
        FlickRaw.url_photopage(pic_info)
      rescue NoMethodError
        # Use pic_info hash to construct URL if it's a Picture object with pic_info_dump
        if pic_info.respond_to?(:pic_info_dump) && pic_info.pic_info_dump.is_a?(Array) && pic_info.pic_info_dump.first.is_a?(Hash)
          info = pic_info.pic_info_dump.first
          "https://www.flickr.com/photos/#{info['owner']}/#{info['id']}"
        elsif pic_info.respond_to?(:urls) && pic_info.urls.is_a?(Array) && pic_info.urls[0].is_a?(Hash)
          pic_info.urls[0]["_content"].to_s
        else
          raise "Unable to determine photopage URL for #{pic_info.inspect}"
        end
      end
    end

    def find_by_flickr_id(string_id)
      fid, secret = string_id.split('_')
      pic_info = flickr.photos.getInfo(photo_id: fid, secret: secret)
      find_or_initialize_from_pic_info(pic_info)
    end

  end
end