#!/bin/bash

# 设置日志文件路径
LOG_FILE="/path/to/your/log/file.log"

# 过滤出最后一次"主机DB失去心跳"的日志并获取时间戳
timestamp=$(grep "主机DB失去心跳" "$LOG_FILE" | tail -n 1 | awk '{print $1}')

# 将时间戳转换为Unix时间戳，并计算前一分钟的时间戳
if [[ ! -z $timestamp ]]; then
    unix_timestamp=$(date -d "${timestamp:1:-1}" +%s)
    previous_minute_timestamp=$((unix_timestamp - 60))

    # 将前一分钟的Unix时间戳转换为[YYYY-mm-dd HH:MM:SS]的格式
    previous_minute=$(date -d "@$previous_minute_timestamp" "+[%Y-%m-%d %H:%M:%S]")

    echo "最后一次主机DB失去心跳时间: $timestamp"
    echo "处理开始时间: $previous_minute"

    # 寻找日志中第一行包含"error reconnecting to master"的行，并获取时间戳
    fault_occurred_timestamp=$(grep "error reconnecting to master" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start' | head -n 1)
    echo "故障发生时间: $fault_occurred_timestamp"

    # 寻找相关事件的时间戳
    pm_stop_request_timestamp=$(grep "send stop service request to PM" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')
    pm_stop_response_timestamp=$(grep "receive stop service success responce from PM" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')
    dn_switch_prepare_timestamp=$(grep "is doing high available switch" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')
    dn_switch_request_timestamp=$(grep "switch request to new master" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')
    dn_switch_complete_timestamp=$(grep "switch master success" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')
    pm_restart_request_timestamp=$(grep "Send Start Service request to PM" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')
    switch_complete_timestamp=$(grep "Receive start Service from PM\[OK\]" "$LOG_FILE" | awk '{print $1}' | awk -v start="$previous_minute" '$1>=start')

    echo "发起PM终止请求的时间: $pm_stop_request_timestamp"
    echo "完成PM终止请求的时间: $pm_stop_response_timestamp"
    echo "准备开始DN高可用切换的时间: $dn_switch_prepare_timestamp"
    echo "发起DN高可用切换的时间: $dn_switch_request_timestamp"
    echo "完成DN高可用切换的时间: $dn_switch_complete_timestamp"
    echo "发起PM重启请求的时间: $pm_restart_request_timestamp"
    echo "切换完成的时间: $switch_complete_timestamp"
else
    echo "未找到主机DB失去心跳的日志记录"
fi
