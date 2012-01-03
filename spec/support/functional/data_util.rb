module Functional
  module DataUtil
    def reset_viewed_pictures
      Collector.last.pictures.viewed.order('updated_at DESC').limit(50).update_all(viewed: false)
    end

  end
end