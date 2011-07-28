module Collectr
  class FlickrPictureRetriever
    include Collectr::Flickr

    FLICKR_PHOTOS_PER_PAGE = 40

    def initialize(params)
      @module = params[:module]
      @method = params[:method]
      @time_field = params[:time_field]
      @user_id = params[:user_id]
    end

    def get(per_page = nil, page_number = 1, since = nil)
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

    def get_all(since, max_num)
      get_all_by_page(since, max_num, 1)
    end
    private

    def get_all_by_page(since, max = 200, page)
      since = nil unless max.nil?

      result =  get(FLICKR_PHOTOS_PER_PAGE, page, since).to_a

      retrieved_max_num_of_pics = max && FLICKR_PHOTOS_PER_PAGE * page >= max
      unless(retrieved_max_num_of_pics || result.empty?)
        result += get_all_by_page(since, max, page + 1)
      end
      result
    end


    def min_time_field
     ('min_' + @time_field.to_s).to_sym
    end

    def paging_opts(per_page, page_number)
      {}.tap do |h|
        h[:per_page] = per_page || FLICKR_PHOTOS_PER_PAGE
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