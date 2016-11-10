#SaveImages - How to Use These Ruby-files

##TOC
- [Google](##Google)
 - [Authentication](###Authentication)
     - [Refresh Tokenを取得](####Refresh Tokenを取得)
     - [Access Tokenを取得](####Access Tokenを取得)
 - [画像ファイルの保存](###画像ファイルの保存)
     - [Google+](####Google+)
     - [Gmail](####Gmail)
- [Twitter](##Twitter)


##Google
詳しくは[The Google API Client Library for Ruby](https://developers.google.com/api-client-library/ruby/)および[RubyDoc/google-api-client](http://www.rubydoc.info/github/google/google-api-ruby-client/Google)を参照する．
###Authentication
自分がAuthenticated userであることを示すためにAccess Tokenが必要．それを取得するためにはOAuth2.0のClient IDとClient Secretが必要．これは複数のGoogle APIにおいて共通して使える．

####Refresh Tokenを取得
まず[Google API Console](https://console.developers.google.com/?hl=JA)のAPI Managerへアクセスし，新しいプロジェクトを作る．適当な名前で登録する．次にCredentials(認証情報)ページへ行き，Create new Client IDのプルダウンからOAuth Client IDを選択．

![Pull down under Create new Client ID](https://github.com/Naughie/SaveImages/blob/master/Screenshots/CreateOAuthPulldown.png)

Web Applicationを選択し，名前を適当に入力する．redirect先はhttp://localhost:4567にする．

![Create OAuth Client](https://github.com/Naughie/SaveImages/blob/master/Screenshots/CreateOAuth.png)

作成後，Client IDとClient Secretが表示されるのでメモする．Client Secretは他人に知られないように注意する．

Libraryから，必要なAPIをEnableする．ここではGoogle+ APIとGmail APIを有効にする．

`auth.sh`(名前は適当)に以下の内容を書き込む．ただし`scope`と`code`と`refresh_token`は後で追記する．

```
client_id="" #your oauth client id
client_secret="" #your oauth client secret
redirect_uri="http://localhost:4567"
scope="" #get later
code="" #get later
refresh_token="" #get later
echo "https://accounts.google.com/o/oauth2/auth?client_id=${client_id}&redirect_uri=${redirect_uri}&scope=${scope}&response_type=code&approval_prompt=force&access_type=offline"
#curl -d client_id=${client_id} -d client_secret=${client_secret} -d redirect_uri=${redirect_uri} -d grant_type=authorization_code -d code=${code} https://accounts.google.com/o/oauth2/token
#echo "{\n  \"web\" : {\n    \"client_id\" : \"${client_id}\",\n    \"client_secret\" : \"${client_secret}\",\n    \"redirect_uri\" : \"${redirect_uri}\",\n    \"scope\" : \"${scope}\",\n    \"refresh_token\" : \"${refresh_token}\"\n  }\n}" > auth.json
```

`auth.json`はRuby内での認証に用いる．`touch auth.json`とでもしておく．`scope`は以下を参照して選ぶ．

- [Google+](https://developers.google.com/+/web/api/rest/oauth): https://www.googleapis.com/auth/plus.loginでよい．
- [Gmail](https://developers.google.com/gmail/api/auth/scopes): https://mail.google.com/でよい．

複数のscopeを選ぶときは，半角スペースで区切る．たとえば

```
scope="https://www.googleapis.com/auth/plus.login https://mail.google.com/"
```

とする．`auth.sh`を実行し，echoされたURLをブラウザで開く．すると上で選択したscopeについて許可を求められるので，許可する．`&response_type=code`としているので，redirectされたページのURLの&code=以下がAuthorization Codeとなる．このAuthorization Codeを`auth.sh`の`code`に代入する．先程の`echo`をコメントアウトし(`#echo`)，その下の`#curl`のhashを取り除く．すなわち次のようにする．

```
client_id="" #your oauth client id
client_secret="" #your oauth client secret
redirect_uri="http://localhost:4567"
scope="" #your scopes
code="" #your authorization code
refresh_token="" #get later
#echo "https://accounts.google.com/o/oauth2/auth?client_id=${client_id}&redirect_uri=${redirect_uri}&scope=${scope}&response_type=code&approval_prompt=force&access_type=offline"
curl -d client_id=${client_id} -d client_secret=${client_secret} -d redirect_uri=${redirect_uri} -d grant_type=authorization_code -d code=${code} https://accounts.google.com/o/oauth2/token
#echo "{\n  \"web\" : {\n    \"client_id\" : \"${client_id}\",\n    \"client_secret\" : \"${client_secret}\",\n    \"redirect_uri\" : \"${redirect_uri}\",\n    \"scope\" : \"${scope}\",\n    \"refresh_token\" : \"${refresh_token}\"\n  }\n}" > auth.json
```

この状態で`auth.sh`を実行すると，`access_token`，`expires_in`，`id_token`，`refresh_token`，`token_type`がjson形式で出力される．Access Tokenには有効期限があり，`expires_in`秒間である．なのでプログラムの実行に時間がかかるのならAccess Tokenを適切に再取得しなければならない．Refresh Tokenは期限切れしない．Refresh Tokenを`auth.sh`の`refresh_token`へ代入し．`curl`をコメントアウトし，最終行の`echo`を実行する．

```
client_id="" #your oauth client id
client_secret="" #your oauth client secret
redirect_uri="http://localhost:4567"
scope="" #your scopes
code="" #your authorization code
refresh_token="" #your refersh token
#echo "https://accounts.google.com/o/oauth2/auth?client_id=${client_id}&redirect_uri=${redirect_uri}&scope=${scope}&response_type=code&approval_prompt=force&access_type=offline"
#curl -d client_id=${client_id} -d client_secret=${client_secret} -d redirect_uri=${redirect_uri} -d grant_type=authorization_code -d code=${code} https://accounts.google.com/o/oauth2/token
echo "{\n  \"web\" : {\n    \"client_id\" : \"${client_id}\",\n    \"client_secret\" : \"${client_secret}\",\n    \"redirect_uri\" : \"${redirect_uri}\",\n    \"scope\" : \"${scope}\",\n    \"refresh_token\" : \"${refresh_token}\"\n  }\n}" > auth.json
```

これによって，`auth.json`の中身は以下のようになる．

```
{
  "web" : {
    "client_id" : "your client id",
    "client_secret" : "your client secret",
    "redirect_uri" : "http://localhost:4567",
    "scope" : "your scopes",
    "refresh_token" : "your refresh token"
  }
}
```

####Access Tokenを取得
RubyGemsを使って`gem install google-api-client`する．Rubyファイルに以下のコードを書き込む．例としてGoogle+についてauthenticateする．Gmailの場合は`plus`を`gmail`に置き換えればよい．

```ruby:gp.rb
require 'google/apis/plus_v1'
require 'google/api_client/client_secrets'
require 'json'

client_secrets = Google::APIClient::ClientSecrets.load('auth.json')
auth_client = client_secrets.to_authorization

auth_client.grant_type = 'refresh_token'
auth_client.fetch_access_token!

plus = Google::Apis::PlusV1::PlusService.new
plus.authorization = auth_client
```

`grant_type`を指定しなかったときはAuthorization Codeによってauthenticateされるが，Authorization CodeはexpireするのでRefresh Tokenによるauthenticateのほうがよい．

###画像ファイルの保存
####Google+
updateされた日付を`date`，画像ファイルの名前を`file_name`，画像が保存されるディレクトリを`path/dir_name`とし，`path/dir_name/datefile_name`として保存するための`save_image`を定義する．

```
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
```

もしdateが必要ない場合は省略する．URLのファイルが開けなかったときのために例外処理をしている．

あらかじめ対象となるアカウントについて，

```
member_names = {
  qName_1: 'dName_1',
  qName_2: 'dName_2'
}
```

のように列挙しておく．`qName`はアカウントのScreen Name，`dName`は`save_image`の引数`dir_name`となる．実際に`qName`の投稿に添付されたファイルを保存するコードは以下である．

```
member_names.each_key do |key|
  #next page token is needed if the result page is big
  nextPageToken = nil
  #search with query 'qName'; 'ja' stands for japanese;
  #.each can be replaced by [0] or other array-element if necessary
  plus.search_people(key.to_s, language: 'ja', max_results: 1).items.each do |member|
    1.times do
      #list 3 activities of member
      activities = plus.list_activities(member.id, 'public', max_results: 3, page_token: nextPageToken)
      nextPageToken = activities.next_page_token
      activities.items.each do |activity|
        #when each post was updated
        date = activity.updated.to_s
        #if there are attachments
        unless activity.object.attachments.nil? then
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
```

ファイルによって拡張子の有無や種類がバラバラであるから，拡張子のないファイルに対して`.jpg`を付ける以下のコードを書いておく．

```
#cd path
Dir.chdir("path")
#pwd
gp = Dir.pwd
Dir.entries(gp).each do |dir|
  #current directory, parent directory, .DS_Store
  unless dir == '.' || dir == '..' || dir == '.DS_Store' then
    Dir.entries(dir).each do |file|
      unless file == '.' || file == '..' || file == '.DS_Store' then
        #if file has no exten
        unless file =~ /.*\..*/ then
          #mv gp/dir/file gp/dir/file.jpg
          File.rename("#{gp}/#{dir}/#{file}", "#{gp}/#{dir}/#{file}.jpg")
        end
      end
    end
  end
end
```

####Gmail
Gmail APIでは添付ファイルを保存できないのでAppleScriptを利用する．`gm.sh`に，AppleScriptを実行するコマンド`osascript`を記述する．そのためのコードを`gm.rb`に書く．__Google+__と同様に，`path/dir_name/file_name`に保存するとする．dir_nameというGoogleのMail boxにあるメッセージをすべて保存するスクリプトである．

```
def apple_script(dir_name)
  lines = {
    line1: "osascript -e \"tell application \\\"Mail\\\"",
    line2: "set mList to every message in mailbox \\\"#{dir_name}\\\" of account \\\"Google\\\"",
    line3: "repeat with mesA in mList",
    line4: "repeat with mailFile in (mail attachment of mesA)",
    line5: "save mailFile in POSIX file (\\\"path/#{dir_name}/\\\" & name of mailFile)",
    line6: "end repeat",
    line7: "end repeat",
    line8: "end tell"\""
  }
  File.open('gm.sh', 'a') do |file|
    lines.each_key do |line|
      file.puts lines[line]
    end
  end
end

File.open('gm.sh', 'w') do |file|
  file.puts '#!/bin/sh'
end
```

一昨日以降に届いたメッセージについて操作することを想定する．

まず一昨日を表すTimeオブジェクトからyyyy/mm/ddという文字列を作り，`date`とする．

```
now = Time.now
#2 days is 172,800 secs
before_yesterday = now - 172800
date = before_yesterday.strftime("%Y/%m/%d")
```
あらかじめGmailのラベルdNameを作成しておく．自分で作ったラベルのIDは，作成順にLabel\_1，Label\_2, ...などとなる．そして，以下のように対象のアカウントの`dName`(`apple_script`の引数`dir_name`となる)，`mName`(メールアドレス)，`lName`(ラベルのID)からなるハッシュを作っておく．

```
member_names  = {
  dName_1: {
    mail: 'mName_1',
    label: 'lName_1'
  },
  dName_2: {
    mail: 'mName_2',
    label: 'lName_2'
  }
}
```

一昨日以降に`mName`から受信したメッセージすべてにラベル`dName`(IDは`lName`)を付け，それらを保存するAppleScript(を実行するための`osascript`コマンド)を`gm.sh`に出力する．各`dName`について対応する`osascript`を出力するが，検索結果のメッセージが無い場合は出力しない(出力せずに次の`dName`へ進む)．

```
member_names.each_key do |key|
  add_label = Google::Apis::GmailV1::ModifyMessageRequest.new(add_label_ids: ["#{member_names[key][:label]}"])
  begin
    #search messages from mName;
    #after date(day before yesterday) which have attachments
    gmail.list_user_messages('me', q: "from:#{member_names[key][:mail]} after:#{date} has:attachment").messages.each do |message|
      #add label of dName
      gmail.modify_message('me', message.id, modify_message_request_object = add_label)
    end
    apple_script(key.to_s)
  rescue
  end
end
```

`ruby gm.rb`としてから`(ba)sh gm.sh`とすれば，ラベル`dName`のついたメッセージを`path/dName`以下に保存することができる．その後，これらのメッセージから，ラベル`dName`を外さなければならない(もしそうしなければ，次回の実行時に重複してしまう)．そのためのコードを`gm_remove.rb`に書く．`gm_remove.rb`もauthenticateする必要がある．

```
member_names.each_key do |key|
  remove_label = Google::Apis::GmailV1::ModifyMessageRequest.new(remove_label_ids: ["#{member_names[key][:label]}"])
  begin
    #list all messages with label lName
    gmail.list_user_messages('me', q: "label:#{key}").messages.each do |message|
      gmail.modify_message('me', message_id, modify_message_request_object = remove_label)
    end
  rescue
  end
end
```

##Twitter
###Keysを取得する

[Twitter Application Management](https://apps.twitter.com/)でCreate New Appをクリックし，必要事項を記入する．
![Twitter Application Management](https://github.com/Naughie/SaveImages/blob/master/Screenshots/TwitterApplicationManagement.png)
Nameは既存のものは使えない．Websiteにlocalhostは使えないが適当なURLでよい．
![Create Twitter App](https://github.com/Naughie/SaveImages/blob/master/Screenshots/CreateTwitterApp.png)
Developer Agreementにチェックをし，Create your Twitter Applicationをする．このApplicationの管理ページへredirectされるので，Keys and Access Tokensを選ぶ．Application SettingsにあるConsumer Key (API Key)とConsumer Secret (API Secret)をメモしておく．Consumer Secretは他人に知られてはいけない．Access Levelは目的に合ったものを選ぶ．Permissinosメニューから変更できる．

ページ下部にあるYour Access TokenのToken ActionsからCreate my access tokenを選ぶ．Access TokenとAccess Token Secretをメモする．Access Token Secretは他人に知られてはいけない．

###Authentication
Rubyファイルに以下の記述をする．

```
require 'twitter'
require 'json'

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
```

`tw.json`には次のように書いておく．

```
{
  "consumer_key" : "your consumer key (api key)",
  "consumer_secret" : "your consumer secret (api secret)",
  "access_token" : "your access token",
  "access_token_secret" : "your access token secret"
}
```

###画像ファイルの保存
Twitterのタイムラインの投稿に貼られた画像のURLをurlとし，その画像を`path/dir_name/file_name`として保存するための`save_image`を定義する．

```
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
```

対象となるアカウントのIDを`name`，`save_image`の引数となるディレクトリ名を`dName`とし，次のようなhashを作っておく．

```
member_names = {
  name_1: 'dName_1',
  name_2: 'dName_2'
}
```

TwitterのAPI Rate Limitは180/minなので適宜`sleep`しておく(秒指定)．
実際にtweetの添付ファイルを保存するコードは以下の通り．

```
2.times do
  #get 200 tweets in timeline
  client.home_timeline(max_id: max_id, count: 200).each do |tweet|
    #if the tweet is not a retweet and has attachments
    if tweet.retweet? == false && tweet.media? == true then
      #if the tweet is of memer_names
      unless member_names[tweet.user.screen_name.to_sym].nil? then
        dir_name = member_names[tweet.user.screen_name.to_sym]
        tweet.media.each do |media|
          save_image(media.media_url, dir_name)
        end
      end
    end
    max_id = tweet.id unless tweet.retweeted?
  end
end
```
