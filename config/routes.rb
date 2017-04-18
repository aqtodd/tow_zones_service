Rails.application.routes.draw do
  get "/ifttt/v1/status", to: "tow_zones#status"
  post "/ifttt/v1/triggers/parking", to: "tow_zones#index"
  post "/ifttt/v1/test/setup", to: "tow_zones#setup"
end
