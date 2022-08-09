Rails.application.routes.draw do
  root "converters#index"

  post '/convert', to: 'converters#convert'
  get '/download/:id', to: 'converters#download', as: 'download'
end
