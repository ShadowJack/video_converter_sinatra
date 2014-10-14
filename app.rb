require 'sinatra'
require 'sinatra/flash'
require './helpers.rb'
require './Models/video.rb'

enable :sessions

# List of all videos 
get '/videos/?' do
  @videos = Video.all
  haml :index
end

# Form to add a new video
get '/videos/new/?' do
  haml :new
end

# Upload new video to uploads/ folder
# and send to conversion worker
post '/videos/?' do
  if !params['title'] || !params['file'] || !params['file'][:tempfile]
    flash.next[:error] = 'Both title and file fields are required!'
    redirect to '/videos/new'
  elsif Video.upload(params)
    redirect to('/videos')
  else
    haml :upload_error
  end
end

# Download flv file
get '/videos/:id/flv/?' do
  download :flv
end

# Download mp4 file
get '/videos/:id/mp4/?' do
  download :mp4
end

# Show meta information:
# resolution, video bitrate, audio bitrate
get '/videos/:id/meta/?' do
  @video = Video.get params[:id]
  if @video
    haml :meta
  else
    flash.next[:error] = 'Error while getting metadata, sorry.'
    redirect to '/videos'
  end
end

# Removes video from db and from disk
delete '/videos/:id/?' do
  @video = Video.get params[:id]
  logger.info 'Video: ' + @video.inspect
  if @video && @video.remove_from_disk && @video.destroy
    flash.next[:notice] = 'Your video was successfully deleted!'
  else
    flash.next[:error] = 'Can\'t delete this video!'
  end
  redirect to '/videos'
end
