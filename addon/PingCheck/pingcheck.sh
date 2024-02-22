#!/bin/bash

# 現在のスクリプトのディレクトリを取得し、作業ディレクトリとして設定
WORK_DIR=$(cd $(dirname $0);pwd)

# 作業ディレクトリから2階層上のディレクトリを取得し、ノードチェックのディレクトリとして設定
NODE_CHECK_DIR=$(dirname $(dirname $WORK_DIR))

# Slackにメッセージを投稿する共通関数を読み込む
source $NODE_CHECK_DIR/common_nc.sh

# confを読み込む
source $WORK_DIR/pingcheck.conf

# pingcheck.txtを読み込む
CONF_FILE="$WORK_DIR/pingcheck.txt"

if [ ! -f "$CONF_FILE" ]; then
    echo "$CONF_FILE が見つかりません。"
    exit 1
fi

while true; do
    while IFS= read -r line; do
        if [[ "$line" =~ ^wss?:// ]]; then
            { timeout 5 wscat -c "$line" &> /dev/null; status=$?; } || true
            if [ $status -eq 0 ]; then
                if [ "$OUTPUT_INFO" = true ]; then
                    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]: WebSocket接続 $line は成功しました。"
                fi
            else
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]: WebSocket接続 $line に失敗しました。"
                post_to_notify "" "WebSocket接続失敗" "danger" "WebSocket警告" "WebSocket接続 $line に失敗しました。"
            fi
        elif [[ "$line" =~ : ]]; then
            IFS=':' read -r host port <<< "$line"
            if nc -z -w1 $host $port > /dev/null 2>&1; then
                if [ "$OUTPUT_INFO" = true ]; then
                    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]:サーバー $host のポート $port はオープンです。"
                fi
            else
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]:サーバー $host のポート $port に到達できません。"
                post_to_notify "" "ポート到達不能検出" "danger" "ポート警告" "サーバー $host のポート $port に到達できません。"
            fi
        else
            if ping -c 1 "$line" > /dev/null; then
                if [ "$OUTPUT_INFO" = true ]; then
                    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]:サーバー $line はオンラインです。"
                fi
            else
                echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR]:サーバー $line はオフラインまたは到達不能です。"
                post_to_notify "" "Ping検出" "danger" "Ping警告" "サーバー $line はオフラインまたは到達不能です。"
            fi
        fi
    done < "$CONF_FILE"

    sleep $CHECK_INTERVAL
done

