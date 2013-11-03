#!/bin/bash
init_killtree() {
    local pid=$1 child

    for child in $(pgrep -P $pid); do
        init_killtree $child
    done
    [ $pid -ne $$ ] && kill -kill $pid
}

init_killtree $1
