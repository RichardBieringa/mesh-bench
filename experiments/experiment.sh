#!/bin/bash
# set -euo pipefail
IFS=$'\n\t'

# Used to perform load testing experiments on a kubernetes cluster
# running Fortio (https://github.com/fortio/fortio/)


# Global Experiment settings:
# CONNECTIONS: Sets the amount of connections to use for the load testing experiment
# DURATION: Control the duration expressed in human time format (e.g. 30s/1m/3h)
# RESOLUTION: Resolution of the histogram lowest buckets in seconds (default 0.001 i.e 1ms), use 1/10th of your expected typical latency
CONNECTIONS=${CONNECTIONS:-"32"}
DURATION=${DURATION:-"5m"}
RESOLUTION=${RESOLUTION:-"0.00001"}
REPETITIONS=5


# The host of the Fortio REST API which will generate the workload
LOAD_GEN_NS="default"
LOAD_GEN_SVC="load-generator-fortio"
LOAD_GEN_HOST="localhost"
LOAD_GEN_PORT="8080"
LOAD_GEN_ENDPOINT="http://${LOAD_GEN_HOST}:${LOAD_GEN_PORT}/fortio/rest/run"

# Kubernetes cluster domain
CLUSTER_DOMAIN="cluster.local"

# Configures the target of the load test
TARGET_NS="benchmark"
TARGET_SVC="target-fortio"
TARGET_PORT="8080"


# Results Directory
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
RESULTS_DIR="$(cd .. && cd results && pwd 2> /dev/null)"


# Check if dependencies installed
function check_installed {
    if ! command -v $1 &> /dev/null
    then
        echo "$1 not found, exiting..."
        exit 1
    fi

    echo "$1 installed."
}

# Run an HTTP experiment 
# arg1: Output Directory for experiment results
# arg2: Mesh Configuration e.g. "linkerd"
# arg3: Queries Per Second e.g. 3000 (use -1 for unlimited)
# arg4 (optional): Uniform Distribution of requests among threads (default: on)
# arg5 (optional): Do not try to catch up to QPS is falling behind (default: on)
function run_http_experiment {
    # Usage check
    if [[ $# -lt 3 ]]
    then 
        echo "usage: run_http_experiment <outdir> <mesh> <qps> [uniform] [nocatchup]"
        exit 1
    fi

    # Local experiment settings
    D=${1:-${RESULTS_DIR}}
    MESH=$2
    QPS=$3
    UNIFORM=${4:-"on"}
    NOCATCHUP=${5:-"on"}

    # In order to used traefik meshed services it has to use .traefik.mesh DNS
    TARGET="http://${TARGET_SVC}.${TARGET_NS}.svc.${CLUSTER_DOMAIN}:${TARGET_PORT}"
    if [[ $MESH == *"traefik"* ]]
    then
        TARGET="http://${TARGET_SVC}.${TARGET_NS}.traefik.mesh:${TARGET_PORT}"
    fi

    # Formatting for filename/log
    fqps=$QPS
    if [[ $QPS -eq -1 ]]
    then
        fqps="MAX"
    fi

    echo "http_experiment (x ${REPETITIONS})"
    echo "mesh: ${MESH}"
    echo "qps: ${fqps}"
    echo "uniform: ${UNIFORM}"
    echo "nocatchup: ${NOCATCHUP}"
    echo "connections: ${CONNECTIONS}"
    echo "duration: ${DURATION}"
    echo "resolution: ${RESOLUTION}"
    echo "-----------------"
    printf "\n"

    # The URL of the Fortio rest server with query parameters to control the experiment settings
    URL="${LOAD_GEN_ENDPOINT}?url=${TARGET}&qps=${QPS}&t=${DURATION}&c=${CONNECTIONS}&uniform=${UNIFORM}&nocatchup=${NOCATCHUP}&r=${RESOLUTION}"

    # Run experiments and save results to output json
    for i in $(seq ${REPETITIONS})
    do
        NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        FNAME="http_${MESH}_${fqps}_${i}_${NOW}.json"

        echo "http_experiment #${i} @  ${NOW}"
        RES=$(curl -s "$URL")

        if [ $? -eq 0 ]; then
            echo $RES > "${D}/${FNAME}"
        else
            echo "Error connecting to ${URL}"
            exit 1
        fi
    done

}

# Runs an HTTP experiment to test maximum throughput (max QPS)
# Wrapper arround the run_http_experiment function
# Uniform distribution and nocatchup are off to maximise throughput
function run_http_experiment_max_throughput {
    # Usage check
    if [[ $# -lt 1 ]]
    then 
        echo "usage: run_http_experiment_max_throughput <mesh>"
        exit 1
    fi

    # Create output dir if not exist
    D="${RESULTS_DIR}/set-qps"
    mkdir -p $D 

    run_http_experiment $D $1 "-1" "off" "off"
}

# Runs several HTTP experiments using pre-determined QPS values
# Wrapper arround the run_http_experiment function
# Uses a uniform distribution of request among threads
# And sets no catch up on to simulate constant throughput experiments
function run_http_experiment_set_qps {
    # Usage check
    if [[ $# -lt 1 ]]
    then 
        echo "usage: run_http_experiment_set_qps <mesh>"
        exit 1
    fi

    # List of QPS settings for the experiment
    lst=(
        100
        500
        1500
        2500
    )

    # Create output dir if not exist
    D="${RESULTS_DIR}/set-qps"
    mkdir -p $D 

    for q in "${lst[@]}"
    do
        run_http_experiment $D $1 "-1" "on" "on"
    done
}

# Kill backbground jobs (port forwarding on exit)
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

function setup {

    # Check Requirements
    echo "Checking Requirements..."
    check_installed "curl"
    check_installed "kubectl"
    check_installed "grep"
    printf "Requirements installed! ✔️\n\n"

    # Port forward to load generator REST API
    echo "Port Forwarding to Fortio..."

    # Creates temporary file to store output
    output=$(mktemp "${TMPDIR:-/tmp/}$(basename $0).XXX")

    # Start the port forwarding process
    kubectl port-forward -n ${LOAD_GEN_NS} svc/${LOAD_GEN_SVC} ${LOAD_GEN_PORT}:${LOAD_GEN_PORT} &> $output &
    pid=$!

    # Wait until the port forwarding process is ready to accept connections
    until grep -q -i "Forwarding from" $output
    do       
        # Check if port forwarding process is still runningj
        if ! ps $pid > /dev/null 
        then
            echo "Port forwarding stopped" >&2
            exit 1
        fi

        sleep 1
    done
    sleep 1
    printf "Port Forwading Done! ✔️\n\n"
}

function main {
    # Basic pre-checks and setup for experiments
    setup

    # Actual experiments
    run_http_experiment_set_qps "baseline"
    # run_http_experiment_max_throughput "baseline"

    exit 0
}

main