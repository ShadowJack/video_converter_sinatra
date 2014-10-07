helpers do
  def download(type)
    @video = Video.get params[:id]
    if @video && @video[type] && File.exist?(@video[type])
      send_file @video[type], type: type, filename: @video.title
    else
      haml :download_error
    end
  end
end