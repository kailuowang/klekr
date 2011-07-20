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

  resources :pictures, :only => [:show, :destroy, :index] do
    collection do
      get 'slide_show'
      get 'current'
    end
    member do
      put 'fave'
      get 'next'
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


  if ["development", "test"].include? Rails.env
    mount Jasminerice::Engine => "/jasmine"
  end
end
