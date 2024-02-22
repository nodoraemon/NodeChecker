#!/bin/bash
# .envファイルから環境変数を読み込む
source .env

# S3バケット名とユーザー名を環境変数から取得
bucket_Name=$BUCKET_NAME
user_Home="/home/$USER_NAME"  # USER_NAMEの値を使ってホームディレクトリのパスを構築

# バックアップを実行
export AWS_SHARED_CREDENTIALS_FILE=$user_Home/.aws/credentials
cd $user_Home/pluginV2Install/ && ./_plinode_backup.sh -full

# 現在の日時を含んだ新しいバックアップフォルダを作成
backup_folder="/plinode_backups/$(date +'%Y%m%d_%H%M%S')"
mkdir -p "$backup_folder"

# 指定されたファイルを新しいバックアップフォルダにコピー
[ -f $user_Home/.pgpass ] && cp $user_Home/.pgpass "$backup_folder"
[ -f $user_Home/.profile ] && cp $user_Home/.profile "$backup_folder"
[ -f $user_Home/pluginV2/apicredentials.txt ] && cp $user_Home/pluginV2/apicredentials.txt "$backup_folder"
[ -f $user_Home/pluginV2/config.toml ] && cp $user_Home/pluginV2/config.toml "$backup_folder"
[ -f $user_Home/pluginV2/secrets.toml ] && cp $user_Home/pluginV2/secrets.toml "$backup_folder"
[ -f $user_Home/plinode_$(hostname -f).vars ] && cp $user_Home/plinode_$(hostname -f).vars "$backup_folder"
cd /plinode_backups/
[ -f $(ls -t $user_Home/plinode_$(hostname -f)_keys*.json | head -n 1) ] && cp $(ls -t $user_Home/plinode_$(hostname -f)_keys*.json | head -n 1) "$backup_folder"
[ -f $(ls -t /plinode_backups/$(hostname -f)_conf_vars_*.tar.gz.gpg | head -n 1) ] && mv $(ls -t /plinode_backups/$(hostname -f)_conf_vars_*.tar.gz.gpg | head -n 1) "$backup_folder"
[ -f $(ls -t /plinode_backups/$(hostname -f)_plugin_mainnet_db_*.sql.gz.gpg | head -n 1) ] && mv $(ls -t /plinode_backups/$(hostname -f)_plugin_mainnet_db_*.sql.gz.gpg | head -n 1) "$backup_folder"

# AWS CLIを使ってS3に同期
/usr/bin/aws --profile contabo --region default --endpoint-url https://usc1.contabostorage.com s3 sync --delete --exact-timestamps /plinode_backups s3://$bucket_Name/

