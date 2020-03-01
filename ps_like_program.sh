#!/bin/bash

printf "%-20s  | %-20s | %-20s | %-20s | %-20s \n" "Pid" "PPid" "Time" "CMD" "Number of opened Files"
for FILE in `ls /proc | sort -n`; do
  pid=`echo "$FILE"`
  if [[ "$pid" < "a" ]]; then
    time=`[ -f /proc/"$FILE"/status ] && awk '{print $14+$15}' /proc/"$FILE"/stat`
    cmd=`[ -f /proc/"$FILE"/status ] && cat /proc/"$FILE"/status | grep "Name:"`
    ppid=`[ -f /proc/"$FILE"/status ] && cat /proc/"$FILE"/status | grep "PPid:"`
    cmd=`echo ${cmd#Name:}`
    ppid=`echo ${ppid#PPid:}`
    nmbr=0
    for FILE in `[ -f /proc/"$FILE"/status ] && ls /proc/$FILE/fd`; do
      nmbr=`echo "$nmbr+1" | bc`
    done
    [ -n "$pid" -a -n "$ppid" -a -n "$time" -a -n "$cmd" -a -n "$nmbr" ] &&
    printf "%-20s | %-20s | %-20s | %-20s | %-20d \n" "$pid" "$ppid" "$time" "$cmd" "$nmbr"
  fi
done
