# config/routes.rb
Rails.application.routes.draw do
  get 'weather', to: 'weather#show'
end