#!/bin/bash

# 作業ディレクトリの設定
WORK_DIR=$(cd "$(dirname "$0")"; pwd)
NODE_CHECK_DIR=$(dirname "$(dirname "$WORK_DIR")")

# Slackにメッセージを投稿する共通関数の読み込み
source "$NODE_CHECK_DIR/common_nc.sh"

# confファイル読み込み
source "$WORK_DIR/log_monitor.conf"

# ログファイルのベースパス
LOG_FILE_BASE="$HOME/.pm2/logs/NodeStartPM2-error.log"

# 実際のログファイルのパス（ローテーションを考慮）
LOG_FILE="$LOG_FILE_BASE"

# スクリプト開始時のログファイルの行数を取得
if [ -f "$LOG_FILE" ]; then
    last_line_num=$(wc -l < "$LOG_FILE")
else
    last_line_num=0
fi

# patterns.txt からエラーパターンを初期読み込み
function load_patterns {
    IFS=$'\n' read -d '' -r -a patterns < "$WORK_DIR/log_monitor.txt"
}
load_patterns

# patterns.txt ファイルの最終変更日時
last_pattern_update=$(stat -c %Y "$WORK_DIR/log_monitor.txt")

while true; do
    # patterns.txt が更新されたかチェック
    current_update=$(stat -c %Y "$WORK_DIR/log_monitor.txt")
    if [ "$last_pattern_update" -ne "$current_update" ]; then
        load_patterns
        last_pattern_update=$current_update
    fi

    # ログファイルが存在しない場合は、ローテーションされた最新のファイルを探す
    if [ ! -f "$LOG_FILE" ]; then
        LOG_FILE=$(ls -t "$LOG_FILE_BASE"* | head -n 1)
        last_line_num=0
    fi

    # 最後にチェックしたログの行番号からログを読み込む
    current_line_num=$(wc -l < "$LOG_FILE")
    if [ "$last_line_num" -lt "$current_line_num" ]; then
        tail -n +$((last_line_num + 1)) "$LOG_FILE" | while IFS= read -r line; do
            for pattern in "${patterns[@]}"; do
                if echo "$line" | grep -q "$pattern"; then
                    # エラーログをコンソールに出力
                    echo "$pattern $line"
                    # post_to_notify "" "Log Error Detected" "danger" "Log Alert $pattern" "$line" ""
                fi
            done
        done
        last_line_num=$current_line_num
    fi

    # 指定された間隔でチェック
    sleep $CHECK_INTERVAL
done

