module.exports = {
  apps : [{
    name: 'NodeChecker',
    script: './NodeChecker.sh',
    watch: false,
    exec_mode: 'fork',
    max_memory_restart: '100M',
    env: {
      NODE_ENV: 'development',
    },
    env_production : {
      NODE_ENV: 'production',
    },
    // ログ設定を追加
    output: './.logs/out.log', // 標準出力のログファイルのパス
    error: './.logs/error.log', // 標準エラーのログファイルのパス
    //log_date_format: 'YYYY-MM-DD HH:mm:ss', // ログの日付フォーマット
    merge_logs: true, // ログファイルをまとめる
  }]
};
