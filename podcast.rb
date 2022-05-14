require "thor"
require "mp3info"
require "erb"
require "active_support"
require "active_support/core_ext"

class Podcast < Thor
  desc "deploy", "deploy"
  def deploy(number, title, author, description, asset_dir, md_dir)
    artwork = File.join(asset_dir, "artwork.jpg")
    mp3 = File.join(asset_dir, "ep#{number}.mp3")
    wav = File.join(asset_dir, "ep#{number}.wav")

    `lame --tt #{title} --ta #{author} --ty #{Date.today.year} --ti #{artwork} --noreplaygain -q 2 --cbr -b 64 -m m --resample 44.1 --add-id3v2 #{wav} #{mp3}`

    date = Time.current.beginning_of_week(:wednesday).since(1.week).strftime("%Y-%m-%d")
    filesize = File.size(mp3)
    duration = Time.at(Mp3Info.open(mp3).length).utc.strftime("%H:%M:%S")

    File.write(
      File.join(md_dir, "#{number}.md"),
      ERB.new(File.read(File.join(md_dir, "_.md.erb"))).result(binding)
    )

    `gsutil cp #{mp3} gs://nekotobit-episodes/`
  end
end

Podcast.start(ARGV)
