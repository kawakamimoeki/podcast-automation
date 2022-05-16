require "rake"
require "mp3info"
require "erb"
require "active_support"
require "active_support/core_ext"

task :podcast do
  config = YAML.load_file("config.yml")
  project_dir = config["project_dir"]
  markdown_dir = config["markdown_dir"]
  gcs_bucket = config["gcs_bucket"]
  number = config["episode"]["number"]
  title = config["episode"]["title"]
  author = config["episode"]["author"]
  album = config["episode"]["album"]
  description = config["episode"]["description"]

  artwork = File.join(project_dir, "artwork.jpg")
  raw = File.join(project_dir, "ep#{number}-raw.wav")
  mp3 = File.join(project_dir, "ep#{number}.mp3")
  wav = File.join(project_dir, "ep#{number}.wav")

  `ffmpeg -ss 2 -i #{raw} #{wav}`

  `lame --tt #{title} --ta #{author} --tl #{album} --ty #{Date.today.year} --ti #{artwork} --noreplaygain -q 2 --cbr -b 64 -m m --resample 44.1 --add-id3v2 #{wav} #{mp3}`

  `mp3gain -r #{mp3}`

  date = Time.current.beginning_of_week(:wednesday).since(1.week).strftime("%Y-%m-%d")
  filesize = File.size(mp3)
  duration = Time.at(Mp3Info.open(mp3).length).utc.strftime("%H:%M:%S")

  File.write(
    File.join(markdown_dir, "#{number}.md"),
    ERB.new(File.read(File.join(project_dir, "template.erb"))).result(binding)
  )

  `gsutil cp #{mp3} gs://#{gcs_bucket}/`
end
