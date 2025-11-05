Rails.application.routes.draw do
  # 1. Set the root (homepage)
  root to: 'cocktails#index'

  # 2. Define resources for Cocktails, and nest Doses inside them
  resources :cocktails do
    resources :doses, only: [:new, :create]
  end

  # 3. Doses destroy action is separate, as it operates on a dose directly
  resources :doses, only: [:destroy]
end