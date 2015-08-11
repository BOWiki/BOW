Rails.application.routes.draw do

  get '/maps/index', to: 'maps#index'

  get 'agencies/show'

  get '/about', to: 'static#about'
  get '/guidelines', to: 'static#guidelines'
  get '/sitemap', to: redirect("http://bow-sitemaps.s3.amazonaws.com/sitemaps/sitemap.xml.gz", status: 301)

  resources :officers

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resources :users, only: [:show, :edit]

  get '/articles/:id/history', to: 'articles#history', as: :articles_history
  post '/articles/:id/undo', to: 'articles#undo', as: :undo
  resources :articles do
    resources :follows, :only => [:create, :destroy]
    resources :comments
  end

  root 'articles#index'
  resources :users do
    resources :registrations
  end

  # mailbox folder routes
  get "mailbox/inbox" => "mailbox#inbox", as: :mailbox_inbox
  get "mailbox/sent" => "mailbox#sent", as: :mailbox_sent
  get "mailbox/trash" => "mailbox#trash", as: :mailbox_trash

  # conversations
  resources :conversations do
    member do
      post :reply
      post :trash
      post :untrash
    end
  end
end
