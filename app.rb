require 'sinatra'
require './helpers.rb'
require './Models/video.rb'


get '/videos' do
  Video.create()
  @videos = Video.all
  haml :index
end

get '/videos/new' do
  haml :new
end

post '/videos' do
  
end

get '/videos/:id/flv' do
  haml :index
end

get '/videos/:id/mp4' do
  haml :index
end

get '/videos/:id/meta' do
  haml :index
end

delete '/videos/:id' do
end