require 'sidekiq'
require 'streamio-ffmpeg'

##
# Worker for sidekiq background
# video conversion job
class ConvertionWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3  # worker tries to do this job 3 times on failure

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
