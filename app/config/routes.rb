Rails.application.routes.draw do
  # get 'dev_apps/index'
  get 'devapps', to: 'dev_apps#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
