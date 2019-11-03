Rails.application.routes.draw do
  root to: 'toppages#index'
  
  get "/auth/google_oauth2/callback", to: "sessions#create"
  delete "/logout",                   to: "sessions#destroy"

  direct(:login) { "/auth/google_oauth2" }
end
