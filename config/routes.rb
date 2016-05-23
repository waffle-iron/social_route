Rails.application.routes.draw do
  root 'static_pages#dashboard'

  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session, controller: "clearance/sessions", only: [:create]

  resources :users, controller: "clearance/users", only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:create, :edit, :update]
  end

  get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"
  get "/sign_up" => "clearance/users#new", as: "sign_up"
  resources :users

  match '/dashboard', to: 'static_pages#dashboard', via: 'get'
  match '/overview', to: 'static_pages#overview', via: 'get'
  match '/overview/adsets', to: 'static_pages#adset_overview', via: 'get'
  match '/reporting', to: 'static_pages#reporting', via: 'get'

  match '/api/dashboard', to: 'api#dashboard', via: 'get'
  match '/api/overview', to: 'api#overview', via: 'get'
  match '/api/overview/adsets', to: 'api#overview_adets', via: 'get'
  match '/api/reporting', to: 'api#reporting', via: 'get'
end
