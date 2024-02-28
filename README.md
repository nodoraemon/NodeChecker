# NodeChecker

Nodeの状況を監視し、問題が発生した場合はSlackまたはLineに通知します。
このプログラムは pm2 プロセスとして実行されます。

## 前提
SlackのIncoming Webhooks機能を使うため、Webhook URLを取得してください。<br>
Lineの通知を利用したい方はLine Tokenを作成してください<br>

NodeCheckerはユーザーのホームディレクトに配下に配置してください<br>
$HOME/NodeChecker<br>
   ├── addon<br>
   │   ├── Log_monitor<br>
   │   ├── PingCheck<br>
   │   ├── ResourceCheck<br>
   │   └── Sample<br>
   └── other<br>
       ├── LogChange<br>
       └── S3backup<br>
## 手順
### jq bc netcatパッケージのインストール
```
sudo apt-get update
sudo apt install jq bc netcat
```
## *.shに権限を付与
```
cd $HOME/NodeChecker
find . -type f -name "*.sh" -exec chmod +x {} \;
```
### WebhookURLやLineTokenの設定をしてください
```
cd $HOME/NodeChecker
cp common_nc.conf.org common_nc.conf
nano common_nc.conf
```
![image](https://github.com/nodoraemon/NodeChecker/assets/157437955/39cde560-b258-4b4d-bd5b-13ea7da189f0)
### 使い方
NodeChecker/addonフォルダと、その配下のフォルダにあるスクリプトファイル(.sh)が監視スクリプトとして動作します。<br>
ADDON_DIRの直下だけでなく、そのもう1つ下の階層、さらにはそれ以下の階層にある.shファイルもすべて検索の対象になります。<br>
フォルダ内に.ignoreファイルが存在するか、またはフォルダ名が.で始まる場合は、そのフォルダにあるスクリプトは対象外となります。<br>
NodeChecker/Otherフォルダは、おまけ機能です<br>
・S3backup=ContaboのObject StorageにPluginNode2.0をバックアップ<br>
・LogChange=PluginNode2.0のログに関するスクリプト<br>
### 監視プロセスの開始
```
pm2 start NodeChecker.config.js
pm2 -f save

pm2 monit
```
![image](https://github.com/nodoraemon/NodeChecker/assets/157437955/03eca783-6a5a-4875-8dae-7d7acc274fe5)
![image](https://github.com/nodoraemon/NodeChecker/assets/157437955/81bab4fc-cab3-41a6-9609-a10c5482c499)

## めも
###FluxJobを監視するのに便利なスクリプト
https://github.com/AoiToSouma/FluxJobMonit_Slack


