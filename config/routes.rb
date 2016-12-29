Rails.application.routes.draw do
  resources :controlled_vocabularies
  resources :collection_inventory_configurations do
    #get '/collection_inventory_configurations/:id/new_physical_object'
  end
  resources :series
  resources :series_titles
  resources :titles
  resources :collections
  resources :users
  resources :physical_objects
  resources :units
  resources :spreadsheets, only: [:index, :show, :destroy]

  get '/physical_objects/dup/:id', to: 'physical_objects#duplicate', as: 'duplicate_physical_object'
  post '/physical_objects/create_duplicate', to: 'physical_objects#create_duplicate', as: 'create_duplicate_physical_object'
  get '/physical_object_ad_strip', to: 'physical_objects#edit_ad_strip', as: 'edit_ad_strip'
  post '/physical_object_ad_strip', to: 'physical_objects#update_ad_strip', as: 'update_ad_strip'
  get '/physical_object_location', to: 'physical_objects#edit_location', as: 'edit_location'
  post '/physical_object_location', to: 'physical_objects#update_location', as: 'update_location'
  post '/spreadhsheets', to: 'spreadsheets#upload', as: 'spreadsheet_upload'

  # physical objects can be created through the collections, titles, and series controllers
  get '/collections/:id/new_physical_object', to: 'collections#new_physical_object', as: 'collection_new_physical_object'
  post 'collections/:id/create_physical_object', to: 'collections#create_physical_object', as: 'collection_create_physical_object'
  get '/titles/:id/new_physical_object', to: 'titles#new_physical_object', as: 'title_new_physical_object'
  post 'titles/:id/create_physical_object', to: 'titles#create_physical_object', as: 'titles_create_physical_object'
  get '/series/:id/new_physical_object', to: 'series#new_physical_object', as: 'series_new_physical_object'
  post 'series/:id/create_physical_object', to: 'series#create_physical_object', as: 'series_create_physical_object'

  get '/autocomplete_title/', to: 'titles#autocomplete_title', as: 'autocomplete_title'
  get 'autocomplete_title_for_series/:series_id/', to: 'titles#autocomplete_title_for_series', as: 'autocomplete_title_for_series'
  get '/autocomplete_series/', to: 'series#autocomplete_series', as: 'autocomplete_series'
  get '/autocomplete_collection/', to: 'collections#autocomplete_collection', as: 'autocomplete_collection'
  get '/autocomplete_collection_for_unit/:unit_id', to: 'collections#autocomplete_collection_for_unit', as: 'autocomplete_collection_for_uni'

  get '/inventory/', to: 'inventory#index', as: 'inventory'

  get '/test_email/', to: 'physical_objects#test_email', as: 'test_email'

  match '/signin', to: 'sessions#new', via: :get
  match '/signout', to: 'sessions#destroy', via: :delete
  resources :sessions, only: [:new, :destroy] do
    get :validate_login, on: :collection
  end



  root "physical_objects#index"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
