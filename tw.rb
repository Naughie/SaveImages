require 'twitter'
require 'json'
require 'open-uri'
require 'FileUtils'

def save_image(url, dir_name)
  file_name = File.basename(url)
  file_path = "path/#{dir_name}/#{file_name}"
  begin
    open(file_path, 'wb') do |output|
      open(url) do |data|
        output.write(data.read)
      end
    end
  rescue
  end
end

puts "Twitter: wait a minute..."
credential_file = File.open("tw.json").read
credentials = JSON.parse(credential_file)

consumer_key = credentials["consumer_key"]
consumer_secret = credentials["consumer_secret"]
access_token = credentials["access_token"]
access_token_secret = credentials["access_token_secret"]

client = Twitter::REST::Client.new(
  consumer_key: consumer_key,
  consumer_secret: consumer_secret,
  access_token: access_token,
  access_token_secret: access_token_secret
)

member_names = {
  okadanana_1107: 'NanaOkada',
  aeringi_3: 'AeriYokoshima',
  hikari_h_0617: 'HikariHashimoto',
  yahho_sahho: 'SahoIwatate',
  ayana18_48: 'AyanaShinozaki',
  yuirii_murayama: 'YuiriMurayama',
  mionnn_48: 'MionMukaichi',
  o_megu1112: 'MeguTaniguchi',
  seina_fuku48: 'SeinaFukuoka',
  kayoyon213: 'KayokoTakita',
  omorimyu_pon: 'MiyuOmori',
  miyabi_ichigo15: 'MiyabiIno',
  yuuriso_1201: 'YuriOta',
  meguumin_48: 'MegumiMatsumura',
  riripon48: 'RirikaSuto',
  oshimaryoka_48: 'RyokaOshima',
  mikinishino4: 'MikiNishino',
  mogi0_0216: 'ShinobuMogi',
  nattsun20: 'NatsukiKojima',
  katorena_710: 'RenaKato'
}

max_id = client.home_timeline.first.id

2.times do
  #get 200 tweets in timeline
  client.home_timeline(max_id: max_id, count: 200).each do |tweet|
    #if the tweet is not a retweet and has attachments
    if tweet.retweet? == false && tweet.media? == true then
      #if the tweet is of memer_names
      unless member_names[tweet.user.screen_name.to_sym].nil? then
        dir_name = member_names[tweet.user.screen_name.to_sym]
        tweet.media.each do |media|
          puts "Twitter: @#{tweet.user.screen_name}: #{tweet.created_at}"
          save_image(media.media_url, dir_name)
        end
      end
    end
    max_id = tweet.id unless tweet.retweeted?
  end
end

puts 'Twitter: --done'
