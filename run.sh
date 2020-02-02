#!/bin/bash

iterations=${iterations:-3}
nproc=$(nproc)
threads="$(for i in $(seq 0 9); do I=$(bc <<< "ibase=2; 10^$i") ; [[ "$I" -le "$((nproc*2))" ]] && echo $I ; done)"

host=$(jq .host .redis.json | sed 's/"//g')
port=$(jq .port .redis.json | sed 's/"//g')
password=$(jq .password .redis.json | sed 's/"//g')
datastore_type_id=$(cat .datastore_type_id)

size=3
keepalive=1
keyspacelen=42
numreq=1

run_iteration () {
    args=""
    args+=" -h ${host:-localhost}"
    args+=" -p ${port:-6379}"
    [[ -n "$password" ]] && args+=" -a $password"
    args+=" -c $clients"
    args+=" -n $requests"
    args+=" -d $size"
    args+=" -k $keepalive"
    args+=" -r $keyspacelen"
    args+=" -P $numreq"
    test="SET"

    redis-benchmark --csv $args > /tmp/redis-benchmark-$clients-$requests-$size.csv
    cat /tmp/redis-benchmark-$clients-$requests-$size.csv
    cb-client redis-benchmark \
        --clients $clients \
        --requests $requests \
        --size $size \
        --keepalive $keepalive \
        --keyspacelen $keyspacelen \
        --numreq $numreq \
        --datastore-type-id $datastore_type_id \
        < /tmp/redis-benchmark-$clients-$requests-$size.csv
}

for i in $(seq 1 $iterations) ; do
    for thread in $threads ; do
        clients=$((thread*50))
        requests=$((100000*thread))
        echo "Run ${clients} clients ${requests} requests"
        run_iteration
    done
done
