#!/bin/bash

# 固定参数
num_gpus=1
update_count=4
gpu_id=3
prefix_length=10
batch_size=32
learning_rate_stage1=1e-5
learning_rate_stage2=5e-6
epochs=15                    # 训练轮数，全局可调

# 语言设置
src_lang="en"                 # 源语言，可全局调控
tgt_languages=("de" "fr")     # 目标语言列表

# 开始和停止时间（小时和分钟）
start_hour=18
start_minute=30
stop_hour=7
stop_minute=30

# 执行选项
run_stage1=true
run_stage2=true

for language in "${tgt_languages[@]}"; do
  echo "Processing language: $language"

  #### Stage 1 ####
  if [ "$run_stage1" = true ]; then
    cmd_stage1="python src/main.py --num_gpus $num_gpus \
      --mn multi30k \
      --prefix_length $prefix_length \
      --bs $batch_size \
      --update_count $update_count \
      --lr $learning_rate_stage1 \
      --epochs $epochs \
      --test_ds 2016 val \
      --stage caption \
      --src_lang $src_lang \
      --tgt_lang $language \
      --gpu_id $gpu_id"

    echo "Running Stage 1: $cmd_stage1"
    $cmd_stage1
    wait
  fi

  #### Stage 2 ####
  if [ "$run_stage2" = true ]; then
    cmd_stage2="python src/main.py --num_gpus $num_gpus \
      --mn multi30k \
      --prefix_length $prefix_length \
      --bs $batch_size \
      --update_count $update_count \
      --lr $learning_rate_stage2 \
      --epochs $epochs \
      --test_ds 2016 val \
      --stage translate \
      --src_lang $src_lang \
      --tgt_lang $language \
      --lm model_pretrained.pth \
      --gpu_id $gpu_id"

    echo "Running Stage 2: $cmd_stage2"
    $cmd_stage2
    wait
  fi

  #### 测试阶段 ####
  datasets=("2016:flickr" "2017:flickr" "2017:mscoco")

  for dataset in "${datasets[@]}"; do
    IFS=":" read -r test_year test_mode <<< "$dataset"
    check_time

    cmd_test="python src/main.py --num_gpus $num_gpus \
      --mn multi30k \
      --src_lang $src_lang \
      --tgt_lang $language \
      --prefix_length $prefix_length \
      --bs $batch_size \
      --test_ds $test_year $test_mode \
      --stage translate \
      --test \
      --lm model_best_test.pth \
      --gpu_id $gpu_id"

    echo "Running test for year $test_year and mode $test_mode: $cmd_test"
    $cmd_test
    wait
  done
done
