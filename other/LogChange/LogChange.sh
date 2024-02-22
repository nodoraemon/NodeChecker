#!/bin/bash

function stop_pm2 {
    pm2 stop all
    sleep 5
}

function start_pm2 {
    pm2 start all
    sleep 5
    pm2 reset all
}

function install_logrotate {
    stop_pm2
    if dpkg -l | grep logrotate > /dev/null ; then
        echo "logrotate is already installed."
    else
        sudo apt update
        sudo apt install logrotate
        echo "logrotate installed successfully."
    fi
    USER_HOME=$(eval echo ~$USER)
    if [[ ! -f /etc/logrotate.d/plugin-logs ]]; then
        create_logrotate_file
    fi
    sudo logrotate -f /etc/logrotate.d/plugin-logs
    start_pm2
}

function create_logrotate_file {
    USER_HOME=$(eval echo ~$USER)
    if [[ -f /etc/logrotate.d/plugin-logs ]]; then
        cat /etc/logrotate.d/plugin-logs
    else
        sudo bash -c "cat > /etc/logrotate.d/plugin-logs <<EOL
$USER_HOME/.pm2/logs/*.log
$USER_HOME/.plugin/*.log
$USER_HOME/.cache/*.logf
{
    su $USER $USER
    rotate 10
    copytruncate
    daily
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        invoke-rc.d rsyslog rotate >/dev/null 2>&1 || true
    endscript
}
EOL"
        echo "Logrotate file created successfully."
    fi
}

function delete_logs {
    stop_pm2
    USER_HOME=$(eval echo ~$USER)
    rm -rf $USER_HOME/.pm2/logs/*.log*
    rm -rf $USER_HOME/.plugin/*.log*
    rm -rf $USER_HOME/.cache/*.logf*
    echo "Logs deleted successfully."
    start_pm2
}

function force_logrotate {
    stop_pm2
    sudo logrotate -f /etc/logrotate.d/plugin-logs
    echo "Forced log rotation executed successfully."
    start_pm2
}

function change_log_level {
    USER_HOME=$(eval echo ~$USER)
    echo "Select new log level:"
    echo "1. debug"
    echo "2. info"
    echo "3. warn"
    echo "4. error"
    read -p "Choice (1-4): " choice

    case $choice in
        1)
            new_level="debug"
            ;;
        2)
            new_level="info"
            ;;
        3)
            new_level="warn"
            ;;
        4)
            new_level="error"
            ;;
        *)
            echo "Invalid choice. Please try again."
            start_pm2
            return
            ;;
    esac

    sed -i "s/Level = '.*'/Level = '$new_level'/g" $USER_HOME/pluginV2/config.toml
    stop_pm2
    start_pm2
    echo "Log level changed to $new_level successfully."
}

while true; do
    echo "Please select an option:"
    echo "1. Install logrotate"
    echo "2. Create/View logrotate file"
    echo "3. Delete logs"
    echo "4. Force log rotation"
    echo "5. Change log level"
    echo "6. Exit"

    read -p "Choice: " choice

    case $choice in
        1)
            install_logrotate
            ;;
        2)
            create_logrotate_file
            ;;
        3)
            delete_logs
            ;;
        4)
            force_logrotate
            ;;
        5)
            change_log_level
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

