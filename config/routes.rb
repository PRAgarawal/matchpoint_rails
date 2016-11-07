Rails.application.routes.draw do
  devise_for :users, :controllers => {
      :registrations => 'registrations'
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'static_pages#index'

  resources :users, except: [:create] do
    collection do
      post 'add_friend/:friend_finder', to: 'users#add_friend', as: 'add_friend',
           constraints: { friend_finder: /[^\/]+/ }
      post 'invite_friend/:email', to: 'users#invite_friend', as: 'invite_friend',
           constraints: { email: /[^\/]+/ }
      put 'accept_friendship/:friend_id', to: 'users#accept_friendship', as: 'accept_friendship'
      delete 'destroy_friendship/:friend_id', to: 'users#destroy_friendship', as: 'destroy_friendship'
    end
  end

  resources :matches do
    collection do
      post 'join/:match_id', to: 'matches#join', as: 'join'
      delete 'leave/:match_id', to: 'matches#leave', as: 'leave'
    end
  end
  resources :courts, only: [:index] do
    collection do
      post 'join/:court_id', to: 'courts#join', as: 'join'
      delete 'leave/:court_id', to: 'courts#leave', as: 'leave'
    end
  end
  resources :messages, only: [:index, :create]

  match '/asset/*path', to: 'assets#serve_main_asset', via: :get
  match '/main/*path', to: 'assets#serve_main_asset', via: :get
end
