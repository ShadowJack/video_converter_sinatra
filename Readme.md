Video converter sinatra
=======================

Info
----
Simple sinatra app that allowes user to upload flv video,
than converts it in background into mp4. After that user can download both
flv and mp4 videos and get meta information about these files such as
resolution, video bitrate and audio bitrate.

Dependencies
------------
* Sinatra
* DataMapper
* MySQL and dm-mysql-adapter
* FFMpeg
* Redis

Install
-------
To run it on your server:

1. Change DataMapper.setup line in models/video.rb file to your MySQL db.
2. Install redis to use [sidekiq](https://github.com/mperham/sidekiq)
3. Install ffmpeg in your system, be shure to add folder with your ffmpeg binary into PATH variable
3. In project folder run `sidekiq -C config/sidekiq.yml -r ./app.rb`
4. Run `ruby app.rb`