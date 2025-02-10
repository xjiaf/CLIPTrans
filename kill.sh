#!/bin/bash

# 使用说明
usage() {
    echo "用法: $0 {run|multi_run|wmt_run}"
    echo "  run        - 终止 run.sh 及其关联的 src/main.py 进程"
    echo "  multi_run  - 终止 multi_run.sh 及其启动的所有 src/main.py 进程"
    echo "  wmt_run    - 终止 wmt_run.sh 及其关联的进程"
    exit 1
}

# 确认函数
confirm() {
    while true; do
        read -p "是否继续杀死这些进程？(y/n): " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo "操作已取消。"; exit;;
            * ) echo "请回答 y 或 n。";;
        esac
    done
}

# 获取 wmt_run.sh 及其关联进程
kill_wmt_run() {
    # 获取 wmt_run.sh 的 PID
    pids_wmt_run_sh=$(pgrep -f 'sh wmt_run.sh')

    if [ -z "$pids_wmt_run_sh" ]; then
        echo "未找到 wmt_run.sh 相关的进程。"
    else
        echo "找到 wmt_run.sh 相关的进程：$pids_wmt_run_sh"
    fi

    # 获取 src/main.py 的 PID
    pids_main_py=$(pgrep -f 'src/main.py')

    if [ -z "$pids_main_py" ]; then
        echo "未找到 src/main.py 相关的进程。"
    else
        echo "找到 src/main.py 相关的进程：$pids_main_py"
    fi

    # 如果有需要杀死的进程，确认后执行
    if [ -n "$pids_wmt_run_sh" ] || [ -n "$pids_main_py" ]; then
        confirm
        if [ -n "$pids_wmt_run_sh" ]; then
            echo "正在终止 wmt_run.sh 进程：$pids_wmt_run_sh"
            kill -15 $pids_wmt_run_sh
            sleep 2
            kill -9 $pids_wmt_run_sh 2>/dev/null
        fi
        if [ -n "$pids_main_py" ]; then
            echo "正在终止 src/main.py 进程：$pids_main_py"
            kill -15 $pids_main_py
            sleep 2
            kill -9 $pids_main_py 2>/dev/null
        fi
        echo "相关进程已终止。"
    else
        echo "没有需要终止的相关进程。"
    fi
}

# 获取 run.sh 及其关联的 src/main.py 进程
kill_run() {
    # 获取 run.sh 的 PID
    pids_run_sh=$(pgrep -f 'sh run.sh')

    if [ -z "$pids_run_sh" ]; then
        echo "未找到 run.sh 相关的进程。"
    else
        echo "找到 run.sh 相关的进程：$pids_run_sh"
    fi

    # 获取 src/main.py 的 PID
    pids_main_py=$(pgrep -f 'src/main.py')

    if [ -z "$pids_main_py" ]; then
        echo "未找到 src/main.py 相关的进程。"
    else
        echo "找到 src/main.py 相关的进程：$pids_main_py"
    fi

    # 如果有需要杀死的进程，确认后执行
    if [ -n "$pids_run_sh" ] || [ -n "$pids_main_py" ]; then
        confirm
        if [ -n "$pids_run_sh" ]; then
            echo "正在终止 run.sh 进程：$pids_run_sh"
            kill -15 $pids_run_sh
            sleep 2
            kill -9 $pids_run_sh 2>/dev/null
        fi
        if [ -n "$pids_main_py" ]; then
            echo "正在终止 src/main.py 进程：$pids_main_py"
            kill -15 $pids_main_py
            sleep 2
            kill -9 $pids_main_py 2>/dev/null
        fi
        echo "相关进程已终止。"
    else
        echo "没有需要终止的相关进程。"
    fi
}

# 获取 multi_run.sh 及其启动的 src/main.py 进程
kill_multi_run() {
    # 获取 multi_run.sh 的 PID
    pids_multi_run_sh=$(pgrep -f 'sh multi_run.sh')

    if [ -z "$pids_multi_run_sh" ]; then
        echo "未找到 multi_run.sh 相关的进程。"
    else
        echo "找到 multi_run.sh 相关的进程：$pids_multi_run_sh"
    fi

    # 获取所有 src/main.py 的 PID
    pids_main_py=$(pgrep -f 'src/main.py')

    if [ -z "$pids_main_py" ]; then
        echo "未找到 src/main.py 相关的进程。"
    else
        echo "找到所有 src/main.py 相关的进程：$pids_main_py"
    fi

    # 如果有需要杀死的进程，确认后执行
    if [ -n "$pids_multi_run_sh" ] || [ -n "$pids_main_py" ]; then
        confirm
        if [ -n "$pids_multi_run_sh" ]; then
            echo "正在终止 multi_run.sh 进程：$pids_multi_run_sh"
            kill -15 $pids_multi_run_sh
            sleep 2
            kill -9 $pids_multi_run_sh 2>/dev/null
        fi
        if [ -n "$pids_main_py" ]; then
            echo "正在终止所有 src/main.py 进程：$pids_main_py"
            kill -15 $pids_main_py
            sleep 2
            kill -9 $pids_main_py 2>/dev/null
        fi
        echo "相关进程已终止。"
    else
        echo "没有需要终止的相关进程。"
    fi
}

# 主逻辑
if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    run)
        kill_run
        ;;
    multi_run)
        kill_multi_run
        ;;
    wmt_run)
        kill_wmt_run
        ;;
    *)
        usage
        ;;
esac
