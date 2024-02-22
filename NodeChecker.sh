#!/bin/bash

# NodeCheckerが配置されているディレクトリのパスを取得
NODE_CHECK_DIR=$(cd $(dirname $0); pwd)
ADDON_DIR="$NODE_CHECK_DIR/addon"

# commonの読み込み
source "$NODE_CHECK_DIR/common_nc.conf"
source "$NODE_CHECK_DIR/common_nc.sh"

# 監視インターバル秒数（例: 60秒）
CHECK_INTERVAL=60

# 子プロセスのPIDを格納するための連想配列を宣言
declare -A pids

# SIGINTとSIGTERMシグナルを受け取った際に子プロセスを終了するトラップを設定
trap 'for pid in "${pids[@]}"; do kill -SIGTERM $pid 2>/dev/null; done' SIGINT SIGTERM

# addonディレクトリおよびそのサブディレクトリから.shファイルを探し、配列に格納
addon_scripts=($(find $ADDON_DIR -type f -name "*.sh"))

# メインの監視ループ
while true; do
    # addon_scripts配列に格納されている各addonスクリプトを実行
    for script in "${addon_scripts[@]}"; do
        script_dir=$(dirname "$script")  # スクリプトがあるディレクトリのパス
        base_dir_name=$(basename "$script_dir")  # ディレクトリのベース名

        # .ignoreファイルの存在チェックとフォルダ名が.で始まるかのチェック
        if [[ -f "$script" && -x "$script" && ! -f "$script_dir/.ignore" && ! "$base_dir_name" =~ ^\. ]]; then
            # スクリプトが実行可能で、.ignoreファイルがなく、フォルダ名が.で始まっていない場合

            # 以前に実行されていないか、またはプロセスが存在しない場合に実行
            if [[ -z "${pids[$script]}" || ! -d "/proc/${pids[$script]}" ]]; then
                "$script" &  # スクリプトをバックグラウンドで実行
                pids[$script]=$!  # 実行したスクリプトのPIDをpids配列に保存
            fi

            # MONITOR_INFOがtrueの場合に限り、スクリプトの実行情報をechoで表示
            if [ "$MONITOR_INFO" = true ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]:$script PID: ${pids[$script]}"
            fi
        fi
    done

    # 指定されたインターバルで待機
    sleep $CHECK_INTERVAL
done

