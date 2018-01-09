Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  root 'main#index'

  post '/update' => 'main#update'

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', passwords: 'users/passwords' }

  resources :products do
    resources :tiles
    resources :publishes, only: [:create]

    collection do
      post 'order' => 'products#update_products_order'
    end

    member do
      post 'tiles-order' => 'products#update_tiles_order'

      post 'approve'
      post 'disapprove'
    end
  end

  resource :public_products do
    get '/:slug' => 'public_products#show'
  end

  resources :users, only: [:show] do
    collection do
      get 'current'
    end
  end

  resources :groups, only: [:index, :show, :create, :update, :destroy] do
    resources :invitations, only: [:create] do
      post 'accept'
      post 'decline'
    end
    resources :applications, only: [:create] do
      post 'accept'
      post 'decline'
    end
  end

  resources :tags, only: [:index, :show, :create]

  namespace :admin do
    get '/' => 'products#index'

    resources :users

    resources :products do
      member do
        get 'approve'
        get 'disapprove'
      end
    end

    resources :tags do
      member do
        get 'approve'
        get 'disapprove'
      end
    end
  end

  get '/:slug' => 'main#index'
  get '/tag/:tag_name' => 'main#index'

  get '*unmatched_route', to: 'main#redirect404'
end
