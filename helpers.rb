helpers do
  def download(type)
    @video = Video.get params[:id]
    video_type = @video[type] if @video
    if video_type && File.exist?(video_type)
      send_file video_type, type: type, filename: @video.title
    else
      haml :download_error
    end
  end
  end