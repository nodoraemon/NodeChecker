#!/bin/bash

# Step 02: Contabo Backup Object Strageの初期設定確認
read -p "Contabo Backup Object Strageの初期設定を続けますか？ [yes/no]: " proceed
if [[ $proceed != "yes" ]]; then
    echo "初期設定を中止しました。"
    exit 1
fi

# Step 01: .envファイルに必要な情報を設定
# デフォルト値の取得
default_bucket_name=$(hostname | tr '[:upper:]' '[:lower:]')
default_user_name=$(whoami)

# ユーザー入力の取得（デフォルト値付き）
read -p "バケット名を入力してください [デフォルト: $default_bucket_name]: " bucket_name
bucket_name=${bucket_name:-$default_bucket_name}

read -p "ユーザー名を入力してください [デフォルト: $default_user_name]: " user_name
user_name=${user_name:-$default_user_name}

# .envファイルへの書き込み
echo "BUCKET_NAME=$bucket_name" > .env
echo "USER_NAME=$user_name" >> .env

# Step 03: awscliのインストール
echo "awscliをインストールしています..."
sudo apt update
sudo apt install -y awscli

# Step 04: AWS CLIの設定
echo "AWS CLIの設定を行います。"
aws configure --profile contabo

# AWS CLIを使ってバケットを自動作成
echo "バケットを作成しています: $bucket_name"
aws --profile contabo --region default --endpoint-url https://usc1.contabostorage.com s3 mb s3://$bucket_name

echo "Contabo Backup Object Storage の初期設定が完了しました。"

