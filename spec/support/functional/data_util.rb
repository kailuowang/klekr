module Functional
  module DataUtil
    def reset_viewed_pictures
      collector.pictures.viewed.order('updated_at DESC').limit(100).update_all(viewed: false)
    end

    def reset_faved_pictures
      Collectr::PictureRepo.new(collector).new_pictures(offset: 0, limit: 100).update_all(rating: 0, faved_at: nil)
    end

    def clear_faved_pictures(conditions = {})
      collector.pictures.faved.where(conditions).update_all(rating: 0)
    end

    def add_faved_pictures(extra = {}, number = 60)
      collector.pictures.limit(number).update_all(extra.merge(rating: 1))
    end

    def reset_sync_status status
      collector.update_attribute(:collection_synced, status)
    end

    def create_some_faved_pictures
      if(collector.pictures.where(rating: 3).count < 20)
        collector.pictures.where(rating: 1).limit(20).update_all(rating: 3)
      end

      if(collector.pictures.where(rating: 2).count < 20)
        collector.pictures.where(rating: 1).limit(20).update_all(rating: 2)
      end
    end
    
    def latest_viewed_picture
      picture = collector.pictures.order('created_at DESC').first
      unless picture.viewed?
        picture.update_attribute(:viewed, true)
      end
      picture
    end

    def collector
      @collector ||= Collector.last
    end
  end
end