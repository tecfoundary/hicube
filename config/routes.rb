Hicube::Engine.routes.draw do
  
  # root 'pages#show'

  devise_for :users,
    class_name: 'Hicube::User',
    path:        '',
    path_prefix: nil,
    failure_app: 'Hicube::Devise::FailureApp',
    module:      :devise

  resources :pages
    
end

Rails.application.routes.draw do

  get ':id', to: 'hicube/public/pages#show', only: [:show]
  # get '/',        to: 'hicube/pages#show'
  # match '*path'   => 'hicube/pages#show', via: :all

  namespace :public do
    resources :pages, only: [:show]
  end

  get 'hicube/public/pages/:id', to: redirect('/%{id}')
end
