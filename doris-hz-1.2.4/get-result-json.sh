#!/bin/bash

# set -x
if [[ ! -d results ]]; then mkdir results; fi

echo -e "{
    \"system\": \"Apache Doris\",
    \"date\": \"$(date '+%Y-%m-%d')\",
    \"machine\": \"PowerEdgeR540\",
    \"cluster_size\": 1,
    \"comment\": \"\",
    \"tags\": [\"C++\", \"column-oriented\", \"MySQL compatible\", \"ClickHouse derivative\"],
    \"load_time\": $(cat loadtime),
    \"data_size\": $(cat storage_size),
    \"result\": [
$(
    r=$(sed -r -e 's/query[0-9]+,/[/; s/$/],/' result.csv)
    echo "${r%?}"
)
    ]
}
" | tee results/"PowerEdgeR540.json"

