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
    redis-benchmark --csv \
        -h ${host:-localhost} \
        -p ${port:-6379} \
        -a "$password" \
        -c $clients \
        -n $requests \
        -d $size \
        -k $keep_live \
        -r $keyspacelen \
        -P $numreq \
        > /tmp/redis-benchmark-$client-$request-$size.csv 
    cb-client redis-benchmark \
        --clients $clients \
        --requests $requests \
        --size $size \
        --keepalive $keepalive \
        --keyspacelen $keyspacelen \
        --numreq $numreq \
        --datastore-type-id $datastore_type \
        < /tmp/redis-benchmark-$client-$request-$size.csv
}

for i in $(seq 1 $iterations) ; do
    for clients in $threads ; do
        requests=$((100000*client))
        run_iteration
    done
done
