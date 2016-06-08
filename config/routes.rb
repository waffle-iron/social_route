Rails.application.routes.draw do
  root 'static_pages#dashboard'

  match '/profile', to: 'users#profile', via: 'get'

  resources :authentications

  match '/dashboard', to: 'static_pages#dashboard', via: 'get'
  match '/overview', to: 'static_pages#overview', via: 'get'
  match '/overview/adsets', to: 'static_pages#adset_overview', via: 'get'
  match '/reporting', to: 'static_pages#reporting', via: 'get'

  match '/api/dashboard', to: 'api#dashboard', via: 'get'
  match '/api/overview', to: 'api#overview', via: 'get'
  match '/api/overview/adsets', to: 'api#overview_adets', via: 'get'
  match '/api/reporting', to: 'api#reporting', via: 'get'
end
