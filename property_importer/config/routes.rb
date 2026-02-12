# frozen_string_literal: true

Rails.application.routes.draw do
  root "imports#index"

  resources :imports, only: %i[index create show] do
    resources :staged_rows, only: [:destroy], param: :staged_row_id, controller: "imports/staged_rows"
    member do
      get :preview
      patch :preview_update
      get :conflicts
      patch :conflicts_resolve
      get :summary
      post :confirm
      post :rollback
      delete :discard
    end
  end

  resources :properties, only: %i[index show]

  get "design", to: "pages#design"
  get "ideation", to: "pages#ideation"
end
