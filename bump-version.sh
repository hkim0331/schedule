#!/bin/sh

if [ -z $1 ] ; then
  echo "usage: $0 <version>"
  exit
fi

gsed -i -e "s/(define VERSION .*$/(define VERSION \"$1\")/" schedule.rkt
