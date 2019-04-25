#!/usr/bin/env bash
export i=0
echo "Starting script run_to_error and beyond" >> logs.txt
while true; do
    make produce
    make consume
    if [[ $? -ne 0 ]]; then
       echo "$(date) Failed at loop with index ${i}" >> logs.txt
       echo "$(date) Failed at loop with index ${i}"
       let "i=0"
       #break
    else
       let "i=i+1"
    fi

    echo "Run loop with index ${i}"
        echo "Run loop with index ${i}" >> logs.txt
done

echo "Failed at ${i} loops"
echo "$(date) Failed at ${i} loops" >> logs.txt
