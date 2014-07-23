Rails.application.routes.draw do

  root 'home#index'

  resource :search, only: :show

end
