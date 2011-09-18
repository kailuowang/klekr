Collectr::Application.routes.draw do

  resource :authentications, :only => [:show, :destroy] do
    member do
      get 'validate'
    end
  end

  resources :editor_recommendations, :only => [:index, :create]

  resources :collectors, :only => [] do
    member do
      get 'info'
    end
  end


  resources :flickr_streams, :only => [:index, :show, :create] do
    member do
      put 'sync'
      put 'adjust_rating'
      put 'mark_all_as_read'
      post 'pictures'
      put 'subscribe'
      put 'unsubscribe'
    end

    collection do
      post 'import'
      get 'my_sources'
    end

  end

  resources :pictures, :only => [:show] do
    collection do
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
      get 'contacts'
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
