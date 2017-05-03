Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/', to: 'teams#index'
  post '/', to: 'teams#create'
  resources :teams do
    post 'pairs'
    resources :members
  end
end