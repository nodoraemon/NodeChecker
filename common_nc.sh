#!/bin/bash

#---------------------------------------------
#  Post to Slack and LINE Notify
#  $1 : text -> host_name
#  $2 : pretext -> job_name
#  $3 : color -> good/warning/danger
#  $4 : title -> detection type
#  $5 : text -> Job Spec ID
#  $6 : footer -> Detection date and time
#---------------------------------------------

# NodeCheckerの設定ファイルを読み込み
NODE_CHECK_DIR=$HOME/NodeChecker
source $NODE_CHECK_DIR/common_nc.conf

# 実行日時と表示日時の取得
EXE_DATE=$(date +"%Y-%m-%d %T")
DSP_DATE=$(date -d"$EXE_DATE" +"%Y-%m-%dT%T")

# ホスト名とIPアドレスの取得
HOST_NAME=$(hostname -f)
IP_ADDRESS=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
MONITOR_NAME=${1:-"$DSP_DATE":"${HOST_NAME}"_"${IP_ADDRESS}"}

# SlackとLINEに投稿する関数
post_to_notify(){
    local message_for_slack=""
    local message_for_line=""
    local message_for_echo=""

    # Slackへの通知が有効な場合の処理
    if [ $NOTIFY_MODE -eq 1 ] || [ $NOTIFY_MODE -eq 3 ]; then
        message_for_slack="{\"text\": \"${MONITOR_NAME}\", \"attachments\": [{\"pretext\": \"$2\", \"color\": \"$3\", \"title\": \"$4\", \"text\": \"$5\", \"footer\": \"$(date)\", \"footer_icon\": \"https://www.goplugin.co/assets/images/logo.png\"}]}"
        curl -X POST -H 'Content-type: application/json' --data "$message_for_slack" $SLACK_WEBHOOK_URL > /dev/null 2>&1
    fi

    # LINEへの通知が有効な場合の処理
    if [ $NOTIFY_MODE -eq 2 ] || [ $NOTIFY_MODE -eq 3 ]; then
        message_for_line="[$2] $4\n$5\nDetected on: $6\n$MONITOR_NAME"
        curl -X POST -H "Authorization: Bearer $LINE_TOKEN" -F "message=$message_for_line" https://notify-api.line.me/api/notify > /dev/null 2>&1
    fi

    # モニタリング情報の出力が有効な場合の処理（常に実行）
    message_for_echo="$4 $5"
    echo "$message_for_echo"
}

# パラメータが一つでも非ブランクの場合、post_to_notifyを実行
if [ -n "$1" ] || [ -n "$2" ] || [ -n "$3" ] || [ -n "$4" ] || [ -n "$5" ] || [ -n "$6" ]; then
    post_to_notify "$1" "$2" "$3" "$4" "$5" "$6"
fi
