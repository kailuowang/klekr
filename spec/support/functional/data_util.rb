module Functional
  module DataUtil

    def reset_viewed_pictures(num = 100)
      collector.pictures.viewed.order('updated_at DESC').limit(num).update_all(viewed: false)
    end

    def reset_faved_pictures
      Collectr::PictureRepo.new(collector).new_pictures(offset: 0, limit: 100).update_all(rating: 0, faved_at: nil)
    end

    def clear_faved_pictures(conditions = {}, c = collector)
      c.pictures.faved.where(conditions).update_all(rating: 0)
    end

    def add_faved_pictures(extra = {}, number = 60)
      collector.pictures.limit(number).update_all(extra.merge(rating: 1))
    end

    def add_faved_pictures_to_test_collector
      if(test_collector.pictures.empty?)
        test_collector.import_from_flickr 50
      end
      test_collector.pictures.limit(40).update_all(rating: 1)
    end

    def reset_editors_choice_pictures
      editor = Collectr::Editor.new.ensure_editor_collector
      if(editor.pictures.where(rating: 2).empty?)
        editor.import_from_flickr 50
      end
      editor.pictures.limit(100).update_all(rating: 2)
    end

    def reset_sync_status status
      collector.update_attribute(:collection_synced, status)
    end

    def create_some_faved_pictures(num = 20)
      if(collector.pictures.where(rating: 3).count < num)
        collector.pictures.where(rating: 1).limit(num).update_all(rating: 3)
      end

      if(collector.pictures.where(rating: 2).count < num)
        collector.pictures.where(rating: 1).limit(num).update_all(rating: 2)
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
      @collector ||= Collector.find_by_user_id(Collectr::DevFlickrUserId)
    end

    def test_collector
      @test_collector ||= ::Collector.find_or_create( user_id: Collectr::TestFlickrUserId,
                                                      user_name: Collectr::TestFlickrUserName,
                                                      auth_token: Collectr::TestFlickrAuthToken )
    end
  end
end