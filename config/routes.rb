Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => :registrations }

  resources :users

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  match '/dashboard', to: 'static_pages#dashboard', via: 'get'
  match '/overview', to: 'static_pages#overview', via: 'get'
  match '/reporting', to: 'static_pages#reporting', via: 'get'
end
