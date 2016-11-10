require 'google/apis/gmail_v1'
require 'google/api_client/client_secrets'
require 'json'
require 'open-uri'
require 'FileUtils'

client_secrets = Google::APIClient::ClientSecrets.load('gm.json')
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
  AyanaShinozaki: {
    mail: 'ayanan@mm.akb48.co.jp',
    label: 'Label_6'
  },
  SahoIwatate: {
    mail: 'yahosahorinrin@mm.akb48.co.jp',
    label: 'Label_5'
  },
  RenaKato: {
    mail: 'katorena@mm.akb48.co.jp',
    label: 'Label_7'
  }
}

member_names.each_key do |key|
  puts "Gmail: #{key.to_s}: removing a label..."
  remove_label = Google::Apis::GmailV1::ModifyMessageRequest.new(remove_label_ids: ["#{member_labels[key]}"])
  begin
    #list all messages with label lName
    gmail.list_user_messages('me', q: "label:#{member_dirs[key]}").messages.each do |message|
      gmail.modify_message('me', message.id, modify_message_request_object = remove_label)
    end
  rescue
  end
end
puts "Gmail: --done"
