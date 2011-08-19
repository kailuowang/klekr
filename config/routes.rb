Collectr::Application.routes.draw do

  resource :authentications, :only => [:show] do
    member do
      get 'validate'
    end
  end

  resources :flickr_streams, :only => [:index, :destroy, :show] do
    member do
      get 'sync'
      put 'adjust_rating'
      put 'mark_all_as_read'
      post 'pictures'
      put 'subscribe'
      put 'unsubscribe'
    end

    collection do
      get 'sync_all'
      post 'import'
    end

  end

  resources :pictures, :only => [:show] do
    collection do
      get 'current'
      post 'all_viewed'
    end
    member do
      put 'fave'
      put 'unfave'
      put 'viewed'
    end
  end

  resources :users, :only => [:show, :index] do
    member do
      put 'subscribe'
      get 'flickr_stream'
    end
    collection do
      post 'search'
    end
  end

  resource :slideshow, :only => [:show], :controller => :slideshow do
    post 'new_pictures'
    post 'fave_pictures'
    get 'faves'
    get 'flickr_stream'
  end



  if ["development", "test"].include? Rails.env
    mount Jasminerice::Engine => "/jasmine"
  end

  root to: 'slideshow#show'
end
