require 'google/apis/plus_v1'
require 'google/api_client/client_secrets'
require 'json'
require 'open-uri'
require 'FileUtils'

def save_image(url, dir_name, date)
  #name of file in url
  file_name = File.basename(url)
  #file name
  file_path = "path/#{dir_name}/#{date}#{file_name}"
  begin
    open(file_path, 'wb') do |output|
      open(url) do |data|
        #write contents of url into file_path
        output.write(data.read)
      end
    end
  rescue
  end
end

puts 'Google+: wait a minute...'

client_secrets = Google::APIClient::ClientSecrets.load('auth.json')
auth_client = client_secrets.to_authorization

auth_client.grant_type = 'refresh_token'
auth_client.fetch_access_token!

member_names = {
    村山彩希: 'YuiriMurayama',
    茂木忍: 'ShinobuMogi',
    篠崎彩奈: 'AyanaShinozaki',
    岩立沙穂: 'SahoIwatate',
    北澤早紀: 'SakiKitazawa',
    加藤玲奈: 'RenaKato',
    田北香世子: 'KayokoTakita'
}

plus = Google::Apis::PlusV1::PlusService.new
plus.authorization = auth_client

member_names.each_key do |key|
  #next page token is needed if the result page is big
  nextPageToken = nil
  #search with query 'qName'; 'ja' stands for japanese;
  #.each can be replaced by [0] or other array-element if necessary
  plus.search_people(key.to_s, language: 'ja', max_results: 1).items.each do |member|
    1.times do
      list 3 activities of member
      activities = plus.list_activities(member.id, 'public', max_results: 3, page_token: nextPageToken)
      nextPageToken = activities.next_page_token
      activities.items.each do |activity|
        #when each post was updated
        date = activity.updated.to_s
        #if there are attachments
        date = "#{date.split(':')[0]}_"
        unless activity.object.attachments.nil? then
          puts "Google+: #{member_names[key]}: #{date}"
          activity.object.attachments.each do |attachment|
            #type may be photo, album, article, ...
            type = attachment.object_type
            if type == 'album' then
              #album has more than 2 photos
              attachment.thumbnails.each do |thumbnail|
                save_image(thumbnail.image.url, member_names[key], date)
              end
            elsif type == 'photo' then
              save_image(attachment.full_image.url, member_names[key], date)
            end
          end
        end
      end
    end
  end
end

#cd path
Dir.chdir("path")
#pwd
gp = Dir.pwd
Dir.entries(gp).each do |dir|
  #current directory, parent directory, .DS_Store
  unless dir == '.' || dir == '..' || dir == '.DO_Store' then
    Dir.entries(dir).each do |file|
      unless file == '.' || file == '..' || file == '.DS_Store' then
        #if file has no extension
        unless file =~ /.*\..*/ then
          #mv gp/dir/file gp/dir/file.jpg
          File.rename("#{gp}/#{dir}/#{file}", "#{gp}/#{dir}/#{file}.jpg")
        end
      end
    end
  end
end

puts 'Google+: --done'
