Collectr::Application.routes.draw do

  resource :authentications, :only => [:show] do
    member do
      get 'validate'
    end
  end

  resources :flickr_streams, :only => [:index, :destroy] do
    member do
      get 'sync'
      put 'adjust_rating'
      put 'mark_all_as_read'
    end

    collection do
      get 'sync_all'
      post 'import'
    end

  end

  resources :pictures, :only => [:show] do
    collection do
      get 'current'
    end
    member do
      put 'fave'
      put 'viewed'
    end
  end

  resources :cookie_settings, :only => [] do
    member do
      put 'update'
    end
  end

  resources :users, :only => [:show, :index] do
    member do
      put 'subscribe'
    end
    collection do
      post 'search'
    end
  end

  resource :slideshow, :only => [:show], :controller => :slideshow do
    get 'current'
    post 'new_pictures'
  end


  if ["development", "test"].include? Rails.env
    mount Jasminerice::Engine => "/jasmine"
  end
end
