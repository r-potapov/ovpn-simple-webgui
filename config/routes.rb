NewApp::Application.routes.draw do
  get "home/index"
  get "home/about"
  # scope "(:locale)", :locale => /ru|en|ukr/ do
  scope "(:locale)" do
    devise_for :users, :controllers => { :registrations => "users/registrations", :sessions => "users/sessions" }, :path_names => { :sign_in => 'login', :sign_out => 'logout', :sign_up => 'register' }
    resources :users, :except => [:new, :create]
    resources :certificates, :except => [:new, :edit, :update]
    resources :ip, :except => [:index, :new, :edit, :show, :update]
    resources :comments, :except => [:show]
    match '/certificates/download_crt/:id' => 'certificates#download_crt', :as => :download_crt
    match '/certificates/download_key/:id' => 'certificates#download_key', :as => :download_key
    match '/certificates/download_config/:id' => 'certificates#download_config', :as => :download_config
    match '/certificates/download_zip/:id' => 'certificates#download_zip', :as => :download_zip
    match '/certificate/download_ca' => 'certificates#download_ca', :as => :download_ca
    match '/certificate/download_ta' => 'certificates#download_ta', :as => :download_ta
    match '/certificates/download_portable_zip/:id' => 'certificates#download_portable_zip', :as => :download_portable_zip

    match '/users/bann_usr/:id' => 'users#bann_usr', :as => :bann_usr
    match '/users/unbann_usr/:id' => 'users#unbann_usr', :as => :unbann_usr

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
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
    match '/:locale' => "home#index"
    root :to => "home#index"
  #, :as => 'home'
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  end
end
