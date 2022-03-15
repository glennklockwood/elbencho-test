#!/usr/bin/env bash

grab_str_elb() {
    grep WRITE $@ | cut -d, -f 6,23
}

grab_str_ior() {
    awk '/^write.*posix/ {printf("%d,%.2f\n", $15, $2)}' $@
}

if [ -z "$1" ]; then
    if compgen -G "bw.??th*[^e].csv" > /dev/null; then
        echo "Buffered I/O"
        for i in bw.??th*[^e].csv; do grab_str_elb $i;done
        echo 
    fi

    if compgen -G "bw-direct.??threads.*[^e].csv" > /dev/null; then
        echo "Direct I/O"
        for i in bw-direct.??threads.*[^e].csv; do grab_str_elb $i;done
        echo
    elif compgen -G "bw-direct.??threads.*[0-9].out" > /dev/null; then
        echo "Direct I/O"
        for i in bw-direct.??threads.*[0-9].out; do grab_str_ior $i;done
        echo
    fi

    if compgen -G "bw-direct-blockvarpct0.??th*[^e].csv" > /dev/null; then
        echo "Direct I/O, blockvarpct=0"
        for i in bw-direct-blockvarpct0.??th*[^e].csv; do grab_str_elb $i;done
        echo
    fi
else
    for i in $@; do grab_str_elb $i;done
    echo
fi
