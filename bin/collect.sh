#!/bin/bash
# collect.sh - saves one sample of each project source under raw/YYYY-mm-dd/HHMM.ext (UTC)

cd "$(dirname "$0")/.."

# Shufersal 290: read the file list of the store and take the newest PriceFull link
url=$(curl -s -L "https://prices.shufersal.co.il/FileObject/UpdateCategory?catID=2&storeId=290" | grep -o 'https://pricesprodpublic[^"]*' | sed 's/&amp;/\&/g' | sort | tail -1)
if [ -z "$url" ]; then
    echo "Shufersal: no file found"
else
    name=$(echo "$url" | grep -o 'PriceFull[0-9-]*')
    day=$(echo "$name" | cut -d "-" -f 4)     # 20261127
    time=$(echo "$name" | cut -d "-" -f 5)    # 040048 (Israel time)
    local_time="$(echo "$day" | cut -c 1-4)-$(echo "$day" | cut -c 5-6)-$(echo "$day" | cut -c 7-8) $(echo "$time" | cut -c 1-2):$(echo "$time" | cut -c 3-4)"
    seconds=$(TZ=Asia/Jerusalem date -d "$local_time" +%s)
    path=$(date -u -d "@$seconds" +%F/%H%M)
    if [ -z "$seconds" ] || [ -z "$path" ]; then
        echo "Shufersal: could not convert the time $local_time"
    else
        mkdir -p "raw/$(dirname "$path")"
        curl -s -L "$url" > "raw/$path.xml.gz"
        echo "Shufersal: saved raw/$path.xml.gz"
    fi
fi

# Carrefour 437: read the file list and take the newest PriceFull file of the store
name=$(curl -s -L "https://prices.carrefour.co.il/" | grep -o 'PriceFull7290055700007-[0-9]*-437-[0-9]*-[0-9]*' | sort | tail -1)
if [ -z "$name" ]; then
    echo "Carrefour: no file found"
else
    day=$(echo "$name" | cut -d "-" -f 4)
    time=$(echo "$name" | cut -d "-" -f 5)
    local_time="$(echo "$day" | cut -c 1-4)-$(echo "$day" | cut -c 5-6)-$(echo "$day" | cut -c 7-8) $(echo "$time" | cut -c 1-2):$(echo "$time" | cut -c 3-4)"
    seconds=$(TZ=Asia/Jerusalem date -d "$local_time" +%s)
    path=$(date -u -d "@$seconds" +%F/%H%M)
    if [ -z "$seconds" ] || [ -z "$path" ]; then
        echo "Carrefour: could not convert the time $local_time"
    else
        mkdir -p "raw/$(dirname "$path")"
        curl -s -L "https://prices.carrefour.co.il/$day/$name.gz" > "raw/$path.xml.gz"
        echo "Carrefour: saved raw/$path.xml.gz"
    fi
fi

# Bank of Israel: USD/ILS and EUR/ILS of the last 7 days, file named by the run time (UTC)
start=$(date -u -d "-7 days" +%F)
path=$(date -u +%F/%H%M)
mkdir -p "raw/$(date -u +%F)"
curl -s -L "https://edge.boi.gov.il/FusionEdgeServer/sdmx/v2/data/dataflow/BOI.STATISTICS/EXR/1.0/RER_USD_ILS+RER_EUR_ILS?format=csv&startperiod=$start" > "raw/$path.csv"
echo "Bank of Israel: saved raw/$path.csv"
