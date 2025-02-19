Rails.application.routes.draw do
  
  
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"
  resources :home   
  resources :posts do
    resources :comments
  end
  # config/routes.rb
resources :notification do
  member do
    get :read_and_redirect
  end
end

  get 'posts/:id/destroy', to: 'posts#destroy', as: :destroy_posts

  post 'home/:id/follow', to: 'home#follow', as: 'follow'
  post 'home/:id/unfollow', to: 'home#unfollow', as: 'unfollow'
  post 'home/:id/remove', to: 'home#remove', as: 'remove'
  post 'home/:id/friend_request', to: 'home#friend_request', as: 'friend_request'
  post 'home/:id/accept', to: 'home#accept', as: 'accept'
  post 'home/:id/decline', to: 'home#decline', as: 'decline'
  post 'home/:id/cancel', to: 'home#cancel', as: 'cancel' 

  get 'home/:id/show_friend_request', to: 'home#show_friend_request', as: 'show_friend_request'
  get 'home/:id/lfollowing', to: 'home#lfollowing', as: 'lfollowing' 
  get 'home/:id/lfollowers', to: 'home#lfollowers', as: 'lfollowers' 
  get 'home/:id/lfriends', to: 'home#lfriends', as: 'lfriends' 

  post 'likes/create', to: 'likes#create', as: 'likes'
  post 'likes/:id/destroy', to: 'likes#destroy', as: 'destroy_likes' 

end
