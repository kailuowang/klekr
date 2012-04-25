module Collectr
  module PictureControllerHelper
    def data_for(picture)
      if (picture.pic_info)
        {
          id:               picture.string_id,
          largeUrl:         picture.large_url,
          mediumUrl:        picture.medium_url,
          mediumSmallUrl:   picture.medium_small_url,
          smallUrl:         picture.small_url,
          interestingness:  picture.stream_rating.to_i,
          title:            picture.display_title,
          description:      picture.no_longer_valid? ? 'SORRY. This picture is no longer available.' : picture.description,
          flickrPageUrl:    picture.url,
          ownerName:        picture.owner_name,
          ownerId:          picture.owner_id,
          noLongerValid:    picture.no_longer_valid?,
          faved:            picture.faved?,
          favedDate:        picture.faved_at ? picture.faved_at.to_date.to_s(:long) : nil,
          rating:           picture.rating,
          viewed:           picture.viewed?,
          ofCurrentCollector: picture.collector == current_collector,
          inKlekr:          !picture.new_record?,
          dateUpload:       picture.date_upload,
          ownerPath:        user_path(picture.owner_id),
          fromStreams:      picture.flickr_streams.map do |stream|
                              data_for_stream_info(stream)
                            end
        }.merge action_paths_for(picture)
      else
        nil
      end
    end

    def action_paths_for(picture)
      {}.tap do |h|
        h[:getViewedPath]    =      viewed_picture_path(picture) unless picture.new_record?
        h[:favePath]         =      fave_picture_path(picture.string_id)
        h[:unfavePath]       =      unfave_picture_path(picture.string_id)
      end
    end

    def data_list_for(pictures)
      pictures.map do |picture|
        data_for(picture)
      end.compact
    end

    def render_json_pictures(pictures)
      render_json data_list_for(pictures)
    end

    private
    def data_for_stream_info(stream)
      { username: stream.username, type: stream.type_display, path: flickr_stream_path(stream)}
    end

  end
end