Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # devise_scope :user do
  #   delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session, via: 'get'
  # end

  root 'static_pages#dashboard'

  match '/dashboard', to: 'static_pages#dashboard', via: 'get'
  match '/overview', to: 'static_pages#overview', via: 'get'
  match '/overview/adsets', to: 'static_pages#adset_overview', via: 'get'
  match '/reporting', to: 'static_pages#reporting', via: 'get'

  match '/api/dashboard', to: 'api#dashboard', via: 'get'
  match '/api/overview', to: 'api#overview', via: 'get'
  match '/api/overview/adsets', to: 'api#overview_adets', via: 'get'
  match '/api/reporting', to: 'api#reporting', via: 'get'
end
