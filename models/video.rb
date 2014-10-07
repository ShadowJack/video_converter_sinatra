require 'data_mapper'
require 'streamio-ffmpeg'
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
    File.open('uploads/' + video.id.to_s + '.flv', 'w') do |f|
      f.write(params['file'][:tempfile].read)
      meta = get_meta f
      video.update flv:           f.path,
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
    result = {}
    result[:dimensions] = video.resolution
    result[:v_bitrate] = video.video_bitrate
    result[:a_bitrate] = video.audio_bitrate
    result
  end
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize

# Create and update table automatically
Video.auto_upgrade!


class ConvertionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3  # worker tries to do this job 3 times on failure
  
  #Sidekiq::Queue['default'].limit = 1
  
  # Sidekiq::Worker assumes that our 
  # Worker implementation has this method
  def perform(video_id)
    video = Video.get(video_id)
    flv_video = FFMPEG::Movie.new(video.flv)
    options = { 
            resolution: flv_video.resolution,
            video_bitrate: flv_video.video_bitrate,
            audio_bitrate: flv_video.audio_bitrate
    }
    mp4_video = flv_video.transcode('uploads/' + video.id.to_s + '.mp4', options)
    video.update(mp4: mp4_video.path)
  end
end