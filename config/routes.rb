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



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  #  just remember to delete public/index.html.
  root :to => "pictures#slide_show"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
