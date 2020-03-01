#!/bin/bash
LGREEN='\033[1;32m'
NC='\033[0m' 

lynx -dump $1 > site1.txt
while true; do
  lynx -dump $1 > site2.txt
  change=`diff -q site1.txt site2.txt`
  if [[ $change ]]; then
    printf "${LGREEN}Wykryto zmiane:${NC}\n"
    printf "`diff site1.txt site2.txt` \n\n"
    lynx -dump $1 > site1.txt
  fi
  sleep $2
done