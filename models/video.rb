require 'data_mapper'
require './workers/convertion_worker.rb'

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# A MySQL connection:
DataMapper.setup(:default, 'mysql://dbowner:password@localhost/video_sinatra')

##
# Model for video representation
class Video
  include DataMapper::Resource

  property :id,             Serial   # Primary autoincremental key
  property :title,          String   # Video title
  property :flv,            String   # Path to flv file
  property :mp4,            String   # Path to mp4 file
  property :dimensions,     String   # Info about dimensions of video
  property :video_bitrate,  String   # Info about video bitrate
  property :audio_bitrate,  String   # Info about audio bitrate
  property :status,         String   # 'q' queue, 'c' convertion, 'f' finished

  ##
  # Try to create new video from params and move it to uploads folder
  # Hash params - request params
  def self.upload(params)
    video = create(title: params['title'])
    File.open('uploads/' + video.id.to_s + '.flv', 'w') do |file|
      file.write(params['file'][:tempfile].read)
      meta = get_meta file
      video.update flv:           file.path,
                   dimensions:    meta[:dimensions],
                   video_bitrate: meta[:v_bitrate],
                   audio_bitrate: meta[:a_bitrate],
                   status:        'q'
    end
    ConvertionWorker.perform_async(video.id)
  end

  ##
  # Remove this video from disk
  # both flv and mp4 files
  def remove_from_disk
    File.delete @flv if @flv && (File.exist? @flv)
    File.delete @mp4 if @mp4 && (File.exist? @mp4)
    true
    rescue
      p 'Error while deleting files from disk!'
      false
  end

  private

  def self.get_meta(file)
    video = FFMPEG::Movie.new(file.path)
    {
      dimensions: video.resolution,
      v_bitrate: video.video_bitrate,
      a_bitrate: video.audio_bitrate
    }
  end
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize

# Create and update table automatically
Video.auto_upgrade!
