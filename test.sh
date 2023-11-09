#!/bin/bash

# 指定输入文件
input_file="data.txt"

# 逐行读取文件
while IFS= read -r line; do
    # 使用正则表达式来分割每行的列
    if [[ "$line" =~ ^\"(.*)\"\ \"(.*)\"\ \"(.*)\"$ ]]; then
        col1="${BASH_REMATCH[1]}"
        col2="${BASH_REMATCH[2]}"
        col3="${BASH_REMATCH[3]}"
        echo "Column 1: $col1"
        echo "Column 2: $col2"
        echo "Column 3: $col3"
    else
        echo "Skipped: $line (does not contain 3 columns)"
    fi
done < "$input_file"

