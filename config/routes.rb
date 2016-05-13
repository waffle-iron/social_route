Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => :registrations }

  resources :users

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  match '/dashboard', to: 'static_pages#dashboard', via: 'get'
  match '/overview', to: 'static_pages#overview', via: 'get'
  match '/overview/adsets', to: 'static_pages#overview_adsets', via: 'get'
  match '/reporting', to: 'static_pages#reporting', via: 'get'

  match '/api/dashboard', to: 'api#dashboard', via: 'get'
  match '/api/overview', to: 'api#overview', via: 'get'
  match '/api/overview/adsets', to: 'api#overview_adets', via: 'get'
  match '/api/reporting', to: 'api#reporting', via: 'get'
end
