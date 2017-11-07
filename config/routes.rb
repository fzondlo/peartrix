Rails.application.routes.draw do
  get '/', to: 'teams#index'
  post '/', to: 'teams#create'

  resources :teams, only: [:index, :create, :show] do
    post 'pairs'
    get 'show_history'

    resources :members, only: [:create, :show, :destroy]
  end
end