#!/bin/bash

# Bash safe mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

DIR=$(pwd)
NOW=

# Queries per second 
QPS=(
    100
    500
    1000
    1500
    2000
)

FORTIO_ENDPOINT="http://localhost:8080/fortio/rest/run"



echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) - Running Experiment"

for q in ${QPS[@]}; do
    echo $q

    # curl -d@experiments/http.json "http://localhost:8080/fortio/rest/run?jsonPath=.metadata"
    echo "curl -d@$DIR/http-sync.json $FORTIO_ENDPOINT?jsonPath=.metadata"
done

curl -d@$DIR/http-sync.json "$FORTIO_ENDPOINT?jsonPath=.metadata"