Collectr::Application.routes.draw do

  resource :authentications, :only => [:show, :destroy] do
    member do
      get 'validate'
      get 'login'
    end
  end

  resource :health, :only => [:show]

  resources :editor_recommendations, :only => [:index]

  resources :collectors, :only => [] do
    member do
      get 'info'
    end

    resources :group_streams, :only => [:index]
  end

  resources :flickr_streams, :only => [:index, :show, :create] do
    member do
      put 'sync'
      put 'adjust_rating'
      put 'mark_all_as_read'
      put 'subscribe'
      get 'subscribe'
      put 'unsubscribe'
    end

    collection do
      post 'import'
      get 'my_sources'
      post 'sync_many'
      get 'find'
    end

  end

  resources :pictures, :only => [:show] do
    collection do
      post 'all_viewed'
    end
    member do
      put 'fave'
      put 'resync'
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
    get 'new_pictures'
    get 'fave_pictures'
    get 'flickr_stream_pictures'
    get 'exhibit_pictures'
    get 'faves'
    get 'exhibit'
    get 'exhibit_login'
    get 'flickr_stream'
  end

  match 'editors_choice' => 'slideshow#editors_choice'

  if ["development", "test"].include? Rails.env
    mount Jasminerice::Engine => "/jasmine"
  end

  root :to => "authentications#show"
end
