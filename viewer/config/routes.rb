Rails.application.routes.draw do
  get "/auth/google_oauth2/callback" => "sessions#create"
  delete "/logout"                   => "sessions#destroy"

  direct(:login) { "/auth/google_oauth2" }
end
