require 'sinatra'
require './helpers.rb'
require './Models/video.rb'


get '/videos' do
  @videos = Video.all
  haml :index
end

get '/videos/new' do
  haml :new
end

post '/videos' do
  if Video.load( params )
    redirect to('/videos')
  else
    haml :upload_error
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