module Collectr
  class FlickrPictureRetriever
    include Flickr
    FLICKR_PHOTOS_PER_PAGE = 20

    def initialize(params)
      @module = params[:module]
      @method = params[:method]
      @time_field = params[:time_field]
      @user_id = params[:user_id]
    end

    def get(per_page = 10, since = nil, page_number = 1)
      opts = {user_id: @user_id, extras: 'date_upload, owner_name'}.
              merge(paging_opts(per_page, page_number)).
              merge(range_opts(since))
      begin
        flickr.send(@module).send(@method, opts)
      rescue FlickRaw::FailedResponse => e
        Rails.logger.error("failed sync photo from flickr" + e.code.to_s + "\n" + e.msg)
        []
      end
    end

    def get_up_to(up_to, max = 200, page = 1 )
      up_to = nil unless max.nil?

      result =  get(FLICKR_PHOTOS_PER_PAGE, up_to, page).to_a

      retrieved_max_num_of_pics = max && FLICKR_PHOTOS_PER_PAGE * page >= max
      unless(retrieved_max_num_of_pics || result.empty?)
        result += get_up_to(up_to,  max, page + 1)
      end
      result
    end

    private
    def min_time_field
     ('min_' + @time_field.to_s).to_sym
    end

    def paging_opts(per_page, page_number)
      {}.tap do |h|
        h[:per_page] = per_page
        h[:page] = page_number if page_number > 1
      end
    end

    def range_opts(since)
      if since
        { min_time_field => since.to_i }
      else
        {}
      end
    end

  end
end