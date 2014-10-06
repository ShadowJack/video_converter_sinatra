require 'data_mapper'
require 'ffprober'

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
    # move temp file to uploads directory
    File.open('uploads/' + video.id.to_s + '.flv', 'w') do |f|
      f.write(params['file'][:tempfile].read)
      meta = get_meta f
      video.update flv:           f.path,
                   dimensions:    meta[:dimensions],
                   video_bitrate: meta[:v_bitrate],
                   audio_bitrate: meta[:a_bitrate],
                   status:        'q'
    end
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
    ffprobe = Ffprober::Parser.from_file(file.path)
    result = {}
    result[:dimensions] = ffprobe.video_streams[0].width.to_s +
                          'x' +
                          ffprobe.video_streams[0].height.to_s
    result[:v_bitrate] = ffprobe.video_streams[0].bit_rate
    result[:a_bitrate] = ffprobe.audio_streams[0].bit_rate
    result
  end
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize

# Create and update table automatically
Video.auto_upgrade!
