#!/bin/sh

set -e

OPTS='-Drelease-safe'

case "$1" in
    dist)
    #noop
    ;;

    run)
    shift
    zig build run $OPTS $@
    exit 0 #return
    ;;

    *)
    zig build $@ $OPTS
    exit 0 #return
    ;;
esac

cross_compile() {
    echo "dist/$1 ... $OPTS"
    zig build $OPTS -Dtarget=$1 -p dist/$1
}

TARGETS='
x86_64-linux-musl
aarch64-linux-musl
x86_64-linux-gnu
aarch64-linux-gnu
x86_64-macos-gnu
aarch64-macos-gnu
x86_64-windows-gnu
aarch64-windows-gnu
'

for T in $TARGETS; do
    cross_compile $T
done
