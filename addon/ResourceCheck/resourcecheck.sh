#!/bin/bash

# 現在のスクリプトのディレクトリを取得し、作業ディレクトリとして設定
WORK_DIR=$(cd $(dirname $0);pwd)

# 作業ディレクトリから2階層上のディレクトリを取得し、ノードチェックのディレクトリとして設定
NODE_CHECK_DIR=$(dirname $(dirname $WORK_DIR))

# 設定ファイルを読み込み
source $WORK_DIR/resourcecheck.conf

# 共通関数（Slackへのポスト機能）を読み込み
source $NODE_CHECK_DIR/common_nc.sh

# 無限ループでチェックを続ける
while true; do
    # CPU使用率を監視
    cpu_usage=$(mpstat 1 1 | awk '/Average/ {print 100-$NF}')
    if [ "$OUTPUT_INFO" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]:現在のCPU使用率: ${cpu_usage}%"
    fi
    if (( $(echo "$cpu_usage > $CPU_USAGE_THRESHOLD" | bc -l) )); then
        MESSAGE="$(date '+%Y-%m-%d %H:%M:%S') [WARN]:現在のCPU使用率: ${cpu_usage}%"
        post_to_notify "" "高いCPU使用率を検出" "warning" "$MESSAGE" ""
    fi

    # メモリ使用率を監視
    mem_usage=$(free | awk '/Mem/{printf("%.2f", $3/$2*100)}')
    if [ "$OUTPUT_INFO" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]:現在のメモリ使用率: ${mem_usage}%"
    fi
    if (( $(echo "$mem_usage > $MEMORY_USAGE_THRESHOLD" | bc -l) )); then
        mem_report=$(free -h)
	MESSAGE="$(date '+%Y-%m-%d %H:%M:%S') [WARN]:現在のメモリ使用率: ${mem_usage}%\n${mem_report}"
        post_to_notify "" "高いメモリ使用率を検出" "warning" "$MESSAGE" ""
    fi

    # ディスク使用率を監視
    disk_usage=$(df -h | awk '$NF=="/"{print $5}')
    if [ "$OUTPUT_INFO" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]:現在のディスク使用率: ${disk_usage}"
    fi
    if (( $(echo "${disk_usage%\%} > $DISK_USAGE_THRESHOLD" | bc -l) )); then
        disk_report=$(df -h)
	MESSAGE="$(date '+%Y-%m-%d %H:%M:%S') [WARN]:現在のディスク使用率: ${disk_usage}\n${disk_report}"
        post_to_slack "" "高いディスク使用率を検出" "warning" "$MESSAGE" ""
    fi

    # 全てのレコードのチェック後、指定されたインターバルだけ待機
    sleep $CHECK_INTERVAL
done

