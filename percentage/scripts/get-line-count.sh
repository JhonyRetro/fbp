#!/bin/bash

set -euo pipefail

[ $# -lt 2 ] && echo "Usage: $0 <filepath>" && exit 1

if [ -f "$1" ]; then
    line_count_file="$(mktemp)"
    wc -l "$1" | tee "${line_count_file}"
    echo "Line count has been stored in ${line_count_file}"
    exit 0
else
    echo "$0: $1 is not a file"
    exit 2
fi
