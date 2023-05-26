#!/bin/bash

add_agent() {
    username=$1
    newhost=$2
    pw=$3

    ts=$(date +"%m%d%Y%H%M")
    cp ./vc-agent-007 ./vc-agent-007-$ts
    c=$(cat ./vc-agent-007 | jq -c '.')

    agentcount=$(echo $c | jq '.["drv-manual-host-uri"] | length')

    creds="${username}@${pw}"
    pg="${newhost}:${creds}:5432/postgres?sslenabled=true&sslmode=require"

    if [[ $agentcount -eq 1 ]]; then
        outconfig=$(echo $c | jq --arg pg "$pg" '. + { "drv-manual-query-capture": "poll", "drv-manual-host-uri": [.["drv-manual-host-uri"], $pg] }')
        echo $outconfig > ./vc-agent-007
    elif [[ $agentcount -ge 2 ]]; then
        c=$(echo $c | jq --arg pg "$pg" '.["drv-manual-host-uri"] += [$pg]')
        outconfig=$(echo $c | jq '. + { "drv-manual-query-capture": "poll" }')
        echo $outconfig > ./vc-agent-007
    fi
}

remove_agent() {
    hostname=$1

    c=$(cat ./vc-agent-007 | jq -c '.')
    uri=$(echo $c | jq '.[] | .["drv-manual-host-uri"]')
    remove=$(echo $uri | jq -r --arg hostname "$hostname" 'map(select(. | test($hostname) | not))')

    c=$(echo $c | jq --argjson remove "$remove" '.["drv-manual-host-uri"] = $remove')
    outconfig=$(echo $c | jq '. + { "drv-manual-query-capture": "poll" }')
    echo $outconfig > ./vc-agent-007
}

get_agent() {
    c=$(cat ./vc-agent-007 | jq -c '.')

    uri=$(echo $c | jq '.[] | .["drv-manual-host-uri"]')
    count=$(echo $uri | jq length)

    if [[ $count -eq 1 ]]; then
        echo "$count configuration in this file"
        echo $uri
    elif [[ $count -gt 1 ]]; then
        echo "There are $count configurations in this file"
        echo $uri
    fi
}

# Example usage:
# add_agent "username" "newhost" "password"
# remove_agent "hostname"
# get_agent
