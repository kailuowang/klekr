module Functional
  module DataUtil
    def reset_viewed_pictures
      Collector.last.pictures.viewed.order('updated_at DESC').limit(50).update_all(viewed: false)
    end

    def reset_faved_pictures
      Collectr::PictureRepo.new(Collector.last).new_pictures(offset: 0, limit: 50).update_all(rating: 0)
    end

    def clear_faved_pictures
      Collector.last.pictures.faved.update_all(rating: 0)
    end

    def add_faved_pictures
      Collector.last.pictures.limit(60).update_all(rating: 1)
    end
  end
end