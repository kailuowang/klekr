module Collectr
  module SlideshowControllerHelper

    private

    def slideshow_for_stream(stream)
      @stream = stream
      check_stream_access(@stream)
      @more_pictures_path = flickr_stream_pictures_slideshow_path(id: @stream.id)
      @empty_message = "#{@stream} has no pictures."
      render "/slideshow/flickr_stream"
    end


    def render_exhibit
      @exhibit_params = exhibit_params
      respond_to do |format|
        format.rss { exhibit_feed }
        format.html { exhibit_html }
      end
    end

    def exhibit_feed

      @pictures = @collector.collection( 20, 1, exhibit_params.merge(order: 'faved_at desc'))

      render 'slideshow/exhibit_feed', :layout => false
    end

    def exhibit_html

      @more_pictures_path = exhibit_pictures_slideshow_path(params.slice(:collector_id, :order_by))
      @empty_message = "#{@collector.user_name} has not faved any pictures yet."
      @default_filters = default_filters
      render 'slideshow/exhibit'
    end


    def exhibit_params
      params.slice(:collector_id, :rating, :faveDate, :faveDateAfter, :order_by)
    end

    def filter_params
      params.slice(:min_rating, :faved_date, :faved_date_after)
    end

    def render_fave_pictures(collector, opts = {})
      render_json_pictures collector.collection( params[:num].to_i,
                                                 params[:page].to_i,
                                                 opts.merge(filter_params))
    end

    def check_stream_access(stream)
      if(current_collector && stream.collector != current_collector)
        redirect_to user_path(stream.user_id, type: stream.class.name)
      end
    end

    def default_filters
      filtersParams = params.slice(:rating, :faveDate, :faveDateAfter)
      filtersParams.to_json if (filtersParams.present?)
    end

    def set_navigation_links
      @bottom_links = [:editors_choice]
      @disable_navigation = current_collector.blank?
    end


  end
end