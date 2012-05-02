module Collectr
  class FlickrPictureRetriever
    include Collectr::Flickr

    attr_reader :collector

    def self.flickr_photos_per_page
      Settings.default_flickr_photo_retrieve_size
    end

    def initialize(params)
      @module = params[:module]
      @method = params[:method]
      @time_field = params[:time_field]
      @user_id = params[:user_id]
      @id_field = params[:id_field] || :user_id
      @collector = params[:collector]
      @default_per_page = params[:per_page] || FlickrPictureRetriever.flickr_photos_per_page
    end

    def get_module
      if @module.is_a?(Array)
        @module.inject(flickr) { |pm, mname| pm.send(mname)}
      else
        flickr.send(@module)
      end
    end

    def get(per_page = nil, page_number = 1, since = nil, before = nil)
      opts = {@id_field => @user_id, extras: 'date_upload, owner_name, description'}.
              merge(paging_opts(per_page, page_number)).
              merge(range_opts(since, before))
      begin
        get_module.send(@method, opts)
      rescue FlickRaw::FailedResponse => e
        handle_flickr_error(e)
      rescue Timeout::Error => e
        handle_timeout_error(e)
      rescue Errno::ETIMEDOUT => e
        handle_timeout_error(e)
      rescue Errno::ECONNRESET => e
        handle_timeout_error(e)
      rescue Errno::ECONNREFUSED => e
        handle_timeout_error(e)
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
        if(@time_field)
          opts[min_time_field] = since.to_i if since.present?
          opts[max_time_field] = before.to_i if before.present?
        end
      end
    end

    def handle_flickr_error(e)
      handle_error(e, "failed sync #{@module} photo for #{@user_id} from flickr. Response code:" + e.code.to_s + "\n" + e.msg)
    end

    def handle_timeout_error(e)
      handle_error(e, "Timed out when syncing #{@module} photo for #{@user_id} from flickr.") do
        sleep(30)
      end
    end

    def handle_error(e, msg)
      if (Rails.env == 'test')
        raise e
      else
        Rails.logger.error(msg)
        yield if block_given?
        []
      end
    end
  end
end
