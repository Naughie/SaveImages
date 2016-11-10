require 'google/apis/gmail_v1'
require 'google/api_client/client_secrets'
require 'json'
require 'open-uri'
require 'FileUtils'

def apple_script(dir_name)
  lines = {
    line1: "osascript -e \"tell application \\\"Mail\\\"", 
    line2: "set mList to every message in mailbox \\\"#{dir_name}\\\" of account \\\"Google\\\"", 
    line3: "repeat with mesA in mList", 
    line4: "repeat with mailFile in (mail attachment of mesA)", 
    line5: "save mailFile in POSIX file (\\\"path/#{dir_name}/\\\" & name of mailFile)", 
    line6: "end repeat", 
    line7: "end repeat" ,
    line8: "end tell\""
  }
  File.open('gm.sh', 'a') do |file|
    lines.each_key do |line|
      file.puts lines[line]
    end
  end
end

puts "Gmail: wait a minute..."

File.open('gm.sh', 'w') do |file|
  file.puts '#!/bin/sh'
end

now = Time.now
#2 days is 172,800 secs
before_yesterday = now - 172800
date = before_yesterday.strftime("%Y/%m/%d")

client_secrets = Google::APIClient::ClientSecrets.load('auth.json')
auth_client = client_secrets.to_authorization

auth_client.grant_type = 'refresh_token'
auth_client.fetch_access_token!

gmail = Google::Apis::GmailV1::GmailService.new
gmail.authorization = auth_client

member_names = {
  ShinobuMogi: {
    mail: 'mogi-mogi-mogi@mm.akb48.co.jp',
    label: 'Label_2'
  },
  YuiriMurayama: {
    mail: 'yuiringo.0615@mm.akb48.co.jp',
    label: 'Label_3'
  },
  SakiKitazawa: {
    mail: 'saki_mail.for_you@mm.akb48.co.jp',
    label: 'Label_4'
  },
  SahoIwatate: {
    mail: 'yahosahorinrin@mm.akb48.co.jp',
    label: 'Label_5'
  },
  AyanaShinozaki: {
    mail: 'ayanan@mm.akb48.co.jp',
    label: 'Label_6'
  },
  RenaKato: {
    mail: 'katorena@mm.akb48.co.jp',
    label: 'Label_7'
  }
}

member_names.each_key do |key|
  puts "Gmail: #{key.to_s}: adding a label..."
  add_label = Google::Apis::GmailV1::ModifyMessageRequest.new(add_label_ids: ["#{member_names[key][:label]}"])
  begin
    #search messages from mName;
    #after date(day before yesterday) which have attachments
    gmail.list_user_messages('me', q: "from:#{member_names[key][:mail]} after:#{date} has:attachment").messages.each do |message|
      gmail.modify_message('me', message.id, modify_message_request_object = add_label)
    end
    apple_script(key.to_s)
  rescue
    puts "Gmail: #{key.to_s}: no mail found"
  end
end
puts 'Gmail: saving...'
