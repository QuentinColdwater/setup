#!/bin/bash

jqpath=`dirname $0`/container-ip-address.jq
docker network inspect bridge |
    jq --arg       container_name "$1" \
       --from-file $jqpath \
       --raw-output
