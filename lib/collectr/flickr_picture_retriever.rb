module Collectr
  class FlickrPictureRetriever
    include Collectr::Flickr

    FLICKR_PHOTOS_PER_PAGE = 40
    attr_reader :collector

    def initialize(params)
      @module = params[:module]
      @method = params[:method]
      @time_field = params[:time_field]
      @user_id = params[:user_id]
      @collector = params[:collector]
      @default_per_page = params[:per_page] || FLICKR_PHOTOS_PER_PAGE
    end


    def get(per_page = nil, page_number = 1, since = nil, before = nil)
      opts = {user_id: @user_id, extras: 'date_upload, owner_name'}.
              merge(paging_opts(per_page, page_number)).
              merge(range_opts(since, before))
      begin
        flickr.send(@module).send(@method, opts)
      rescue FlickRaw::FailedResponse => e
        handle_flickr_error(e)
      end
    end

    def get_all(since, max_num, &block)
      get_all_by_page(since, max_num, 1, &block)
    end

    private

    def get_all_by_page(since, max, page)
      result =  get(@default_per_page, page, since).to_a
      yield result if(block_given?)
      retrieved_max_num_of_pics = max && @default_per_page * page >= max
      unless(retrieved_max_num_of_pics || result.empty?)
        result += get_all_by_page(since, max, page + 1)
      end
      result
    end


    def time_field(prefix)
      (prefix + @time_field.to_s).to_sym
    end

    def min_time_field
      time_field('min_')
    end

    def max_time_field
      time_field('max_')
    end

    def paging_opts(per_page, page_number)
      {}.tap do |h|
        h[:per_page] = per_page || @default_per_page
        h[:page] = page_number if page_number > 1
      end
    end

    def range_opts(since, before)
      {}.tap do |opts|
        opts[min_time_field] = since.to_i if since.present?
        opts[max_time_field] = before.to_i if before.present?
      end
    end

    def handle_flickr_error(e)
      if (Rails.env == 'test')
        raise e
      else
        Rails.logger.error("failed sync #{@module} photo for #{@user_id} from flickr. Response code:" + e.code.to_s + "\n" + e.msg)
        []
      end
    end

  end
end