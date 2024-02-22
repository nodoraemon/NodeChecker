# NodeChecker

Nodeの状況を監視し、問題が発生した場合はSlackに通知します。
このプログラムは pm2 プロセスとして実行されます。

## 前提
SlackのIncoming Webhooks機能を使うため、Webhook URLを取得してください。<br><br>
Slackの登録方法は以下をご覧ください。<br>
NodeCheckerはユーザーのホームディレクトに配下に配置してください<br>
$HOME/NodeChecker

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
### Webhook URLの設定をしてください
```
cd $HOME/NodeChecker
cp common_nc.conf.org common_nc.conf
nano common_nc.conf
```
### 使い方
NodeChecker/addonフォルダと、その配下のフォルダにあるスクリプトファイル(.sh)が監視スクリプトとして動作します。
ADDON_DIRの直下だけでなく、そのもう1つ下の階層、さらにはそれ以下の階層にある.shファイルもすべて検索の対象になります。
フォルダ内に.ignoreファイルが存在するか、またはフォルダ名が.で始まる場合は、そのフォルダにあるスクリプトは対象外となります。
NodeChecker/Otherフォルダは、おまけ機能です。
### 監視プロセスの開始
```
pm2 start NodeChecker.config.js
pm2 -f save

pm2 monit
```

## めも
###FluxJobを監視するのに便利なスクリプト
https://github.com/AoiToSouma/FluxJobMonit_Slack


