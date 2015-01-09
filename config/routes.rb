require "jsonapi/routing_ext"

Rails.application.routes.draw do
  jsonapi_resources :sports
end
