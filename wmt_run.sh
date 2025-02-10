#!/bin/bash

# 固定参数
num_gpus=1
update_count=4
gpu_id=3
prefix_length=10
batch_size=8
learning_rate_stage1=1e-5
learning_rate_stage2=1e-5
languages=("de" "fr")

# 开始和停止时间（小时和分钟）
start_hour=18
start_minute=30
stop_hour=7
stop_minute=30

# 执行选项
run_stage1=true
run_stage2=true

# 时间检查函数
check_time() {
  current_hour=$(date +%H)
  current_minute=$(date +%M)
  current_day=$(date +%u)
  current_time_in_minutes=$((10#$current_hour * 60 + 10#$current_minute))

  if [ "$current_day" -ge 6 ]; then
    echo "当前是周末，任务允许执行..."
    return 0
  fi

  start_time_in_minutes=$((start_hour * 60 + start_minute))
  stop_time_in_minutes=$((stop_hour * 60 + stop_minute))

  if [ "$start_time_in_minutes" -le "$stop_time_in_minutes" ]; then
    if [ "$current_time_in_minutes" -lt "$start_time_in_minutes" ] || [ "$current_time_in_minutes" -ge "$stop_time_in_minutes" ]; then
      echo "当前时间不在允许的时间范围内（${start_hour}:${start_minute} 到 ${stop_hour}:${stop_minute}），退出..."
      exit 0
    fi
  else
    if [ "$current_time_in_minutes" -lt "$start_time_in_minutes" ] && [ "$current_time_in_minutes" -ge "$stop_time_in_minutes" ]; then
      echo "当前时间不在允许的时间范围内（${start_hour}:${start_minute} 到 ${stop_hour}:${stop_minute}），退出..."
      exit 0
    fi
  fi
}

# 主循环开始
for language in "${languages[@]}"; do
  echo "=== Starting processing for language: $language ==="

  # 检查时间
  check_time

  #### Stage 1 ####
  if [ "$run_stage1" = true ]; then
    cmd_stage1="python src/main.py --num_gpus $num_gpus \
      --mn wmt \
      --prefix_length $prefix_length \
      --bs $batch_size \
      --update_count $update_count \
      --lr $learning_rate_stage1 \
      --test_ds 2016 val \
      --stage caption \
      --tgt_lang $language \
      --gpu_id $gpu_id"

    echo "Running Stage 1 for $language: $cmd_stage1"
    $cmd_stage1
    wait
    check_time
  fi

  #### Stage 2 ####
  if [ "$run_stage2" = true ]; then
    cmd_stage2="python src/main.py --num_gpus $num_gpus \
      --mn wmt \
      --ds wmt \
      --prefix_length $prefix_length \
      --bs $batch_size \
      --update_count $update_count \
      --lr $learning_rate_stage2 \
      --test_ds val val \
      --stage translate \
      --tgt_lang $language \
      --lm model_pretrained.pth \
      --gpu_id $gpu_id"

    echo "Running Stage 2 for $language: $cmd_stage2"
    $cmd_stage2
    wait
    check_time
  fi

  #### 测试阶段 ####
  datasets=("test:test")

  for dataset in "${datasets[@]}"; do
    IFS=":" read -r test_year test_mode <<< "$dataset"
    check_time

    cmd_test="python src/main.py --num_gpus $num_gpus \
      --mn wmt \
      --ds wmt \
      --src_lang en \
      --tgt_lang $language \
      --prefix_length $prefix_length \
      --bs $batch_size \
      --test_ds $test_year $test_mode \
      --stage translate \
      --test \
      --lm model_best_test.pth \
      --gpu_id $gpu_id"

    echo "Running test for language $language, year $test_year and mode $test_mode: $cmd_test"
    $cmd_test
    wait
  done

  echo "=== Completed processing for language: $language ==="
done