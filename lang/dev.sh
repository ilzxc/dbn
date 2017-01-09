#!/bin/sh

fswatch ./dba.pegjs | xargs -n1 ./makelang.sh
