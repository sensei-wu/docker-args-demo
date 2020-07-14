#!/bin/sh
trap "exit" SIGINT
interval=$1
param=$2
echo Configured to generate new fortune every $interval seconds with params $2

while :
do
  fortune $param
  sleep $interval
done
