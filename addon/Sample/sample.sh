#!/bin/bash

# 現在のスクリプトのディレクトリを取得し、作業ディレクトリとして設定
WORK_DIR=$(cd $(dirname $0);pwd)

# 作業ディレクトリから2階層上のディレクトリを取得し、ノードチェックのディレクトリとして設定
NODE_CHECK_DIR=$(dirname $(dirname $WORK_DIR))

# Slackにメッセージを投稿する共通関数を読み込む
source $NODE_CHECK_DIR/common_nc.sh

# Sampleのconfを読み込む
source $WORK_DIR/sample.conf

# テストカウンターの初期化
TEST_COUNTER=0

# メインの監視ループ
while true; do
    # テストカウンターをインクリメント
    ((TEST_COUNTER++))
    post_to_notify "" "TEST" "danger" " [INFO]:  $TEST_COUNTER TESTプログラムです" "" ""

    # 待機時間の指定
    sleep $CHECK_INTERVAL
done

