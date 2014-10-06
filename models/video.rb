require 'data_mapper'

# If you want the logs displayed you have to do this before the call to setup
DataMapper::Logger.new($stdout, :debug)

# A MySQL connection:
DataMapper.setup(:default, 'mysql://dbowner:password@localhost/video_sinatra')

class Video 
  include DataMapper::Resource
  
  property :id,             Serial         # Primary autoincremental key
  property :title,          String         # Video title
  property :flv,            String         # Path to flv file
  property :mp4,            String         # Path to mp4 file
  property :dimensions,     String         # Info about dimensions of video
  property :video_bitrate,  String         # Info about video bitrate
  property :audio_bitrate,  String         # Info about audio bitrate
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize

# Create and update table automatically
Video.auto_upgrade!


