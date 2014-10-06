require 'sinatra'
require './helpers.rb'
require './Models/video.rb'

enable :sessions

get '/videos/?' do
  @videos = Video.all
  haml :index
end

get '/videos/new/?' do
  haml :new
end

post '/videos/?' do
  if !params['title'] || !params['file'][:tempfile]
    flash.next[:error] = 'Both title and file fields are required!'
    redirect to '/videos/new'
  elsif Video.upload(params)
    redirect to('/videos')
  else
    haml :upload_error
  end
end

get '/videos/:id/flv/?' do
  haml :index
end

get '/videos/:id/mp4/?' do
  haml :index
end

get '/videos/:id/meta/?' do
  haml :index
end

delete '/videos/:id' do
  @video = Video.get(params[:id])
  logger.info 'Video: ' + @video.inspect
  if @video && @video.remove_from_disk && @video.destroy
    flash.next[:notice] = 'Your video was successfully deleted!'
  else
    flash.next[:error] = 'Can\'t delete this video!'
  end
  redirect to '/videos'
end
