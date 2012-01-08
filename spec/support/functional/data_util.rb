module Functional
  module DataUtil
    def reset_viewed_pictures
      Collector.last.pictures.viewed.order('updated_at DESC').limit(50).update_all(viewed: false)
    end

    def reset_faved_pictures
      Collectr::PictureRepo.new(Collector.last).new_pictures(offset: 0, limit: 50).update_all(rating: 0, faved_at: nil)
    end

    def clear_faved_pictures(conditions = {})
      Collector.last.pictures.faved.where(conditions).update_all(rating: 0)
    end

    def add_faved_pictures(extra = {}, number = 60)
      Collector.last.pictures.limit(number).update_all(extra.merge(rating: 1))
    end

    def reset_sync_status status
      Collector.last.update_attribute(:collection_synced, status)
    end

    def create_some_faved_pictures
      if(Collector.last.pictures.where(rating: 3).count < 20)
        Collector.last.pictures.where(rating: 1).limit(20).update_all(rating: 3)
      end

      if(Collector.last.pictures.where(rating: 2).count < 20)
        Collector.last.pictures.where(rating: 1).limit(20).update_all(rating: 2)
      end

    end
  end
end