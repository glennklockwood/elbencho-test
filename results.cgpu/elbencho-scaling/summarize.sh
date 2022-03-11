#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Buffered I/O"
    for i in bw.??th*[^e].csv; do grep WRITE "$i" | cut -d, -f 6,23;done
    echo 

    echo "Direct I/O"
    for i in bw-direct.??th*[^e].csv; do grep WRITE "$i" | cut -d, -f 6,23;done
    echo

    echo "Direct I/O, blockvarpct=0"
    for i in bw-direct-blockvarpct0.??th*[^e].csv; do grep WRITE "$i" | cut -d, -f 6,23;done
    echo
else
    for i in $@; do grep WRITE "$i" | cut -d, -f 6,23;done
    echo
fi
