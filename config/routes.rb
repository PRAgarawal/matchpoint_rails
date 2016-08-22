Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'static_pages#index'

  resources :matches do
    collection do
      post 'join/:match_id', to: 'matches#join', as: 'join'
    end
  end

  match '/asset/*path', to: 'assets#serve_main_asset', via: :get
  match '/main/*path', to: 'assets#serve_main_asset', via: :get
end
