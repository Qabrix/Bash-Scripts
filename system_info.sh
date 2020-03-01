#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"

convert_bytes() {
    if (( $(echo "$1 < 1024" | bc) )); then
        printf "%.2f B/s" $1
    elif (( $(echo "$1 < 1048576" | bc) )); then
        echo "$(echo "scale=2; $1/1024" | bc) KB/s"
    else
        echo "$(echo "scale=2; $1/1048576" | bc) MB/s"
    fi
}

output_data(){
    printf "${ORANGE}Current network speed${NC}: ${ARROWDOWN} %s ${ARROWUP} %s\n" "$1" "$2" 
    printf "${ORANGE}Average network speed${NC}: ${ARROWDOWN} %s ${ARROWUP} %s\n" "$3" "$4"
    printf "${ORANGE}Uptime: \n"
    printf "${LGREEN}\tDays: ${NC}%d \n" $5
    printf "${LGREEN}\tHours: ${NC}%d \n" $6
    printf "${LGREEN}\tMinutes: ${NC}%d \n" $7
    printf "${LGREEN}\tSeconds: ${NC}%d \n\n" $8
    printf "${ORANGE}System load: ${NC}%s\n\n" $9
}

prepare_average_netSpeed() {
    avgDownload=0
    avgUpload=0

    for i in {25..1}; do
        arrayDownload[$i]=${arrayDownload[$i-1]} 
        arrayUpload[$i]=${arrayUpload[$i-1]} 
        avgDownload=`echo "($avgDownload+${arrayDownload[i]})" | bc`
        avgUpload=`echo "($avgUpload+${arrayUpload[i]})" | bc`
    done

    arrayDownload[0]=$1
    arrayUpload[0]=$2

    avgDownload=`echo "($avgDownload+${arrayDownload[0]})" | bc`
    avgUpload=`echo "($avgUpload+${arrayUpload[0]})" | bc`
    avgDowload=`echo "$avgDownload/10" | bc`
    avgUpload=`echo "$avgUpload/10" | bc`
    avgDown=$(convert_bytes $avgDowload)
    avgUp=$(convert_bytes $avgUpload)
}

draw_chart() {
    #wybieranie download/upload
    declare arr
    declare DRAWCOLOR
    if [ "$1" -eq "0" ]; then
        printf "${ORANGE}Download speed: \n\n${NC}"
        DRAWCOLOR=$LGREEN
        arr=("${arrayDownload[@]}")
    elif [ "$1" -eq "1" ]; then
        printf "${ORANGE}Upload speed: \n\n${NC}"
        DRAWCOLOR=$MAGENTA
        arr=("${arrayUpload[@]}")
    fi

    max=0.0
    for n in "${arr[@]}"; do
        (( $(echo "$n > $max" | bc) )) && max=$n
    done

    scaler=`echo "scale=2; $max/13" | bc`

    (( $(echo "$max > 0.0" |bc) )) && 
    for i in {0..12}; do
        legend=$(convert_bytes $max)
        printf "${NC}%s " $legend
        addSpaces=$((15 - ${#legend}))
        for ((c=1; c<$addSpaces; c++)); do
            printf " "
        done
        printf "${DRAWCOLOR}"
        for j in {0..25}; do
            if (( $(echo "${arr[$j]} >= $max" | bc) )); then
                printf "\u2588\u2588 "
            else
                printf "   "
            fi
        done
        max=`echo "$max - $scaler" | bc`
        printf "\n"
    done
    printf "${NC}"
}

main() {
    while true; do
        sleep 1
        clear

        downloadMeas2=`awk '/enp0s31f6:/ {print $2}' /proc/net/dev`
        uploadMeas2=`awk '/enp0s31f6:/ {print $10}' /proc/net/dev`

        downloadInBytes=$(($downloadMeas2 - $downloadMeas1))
        uploadInBytes=$(($uploadMeas2 - $uploadMeas1))
        download=$(convert_bytes $downloadInBytes)
        upload=$(convert_bytes $uploadInBytes)
        downloadMeas1=$downloadMeas2
        uploadMeas1=$uploadMeas2

        timeBoot=`awk '{print int($1)}' /proc/uptime`
        upSec=`echo "$timeBoot%60" | bc`
        upMin=`echo "($timeBoot/60)%60" | bc`
        upHr=`echo "($timeBoot/3600)%24" | bc`
        upDays=`echo "($timeBoot/(3600*24))" | bc`

        sysLoad=`awk '{print $4}' /proc/loadavg`

        prepare_average_netSpeed $downloadInBytes $uploadInBytes

        #            1           2         3          4      5       6     7      8      9     
        output_data "$download" "$upload" "$avgDown" "$avgUp" $upDays $upHr $upMin $upSec $sysLoad

        #0 => download 1 => upload
        draw_chart 0
        draw_chart 1
    done
}

LGREEN='\033[1;32m'
ORANGE='\u001b[0;33m'
MAGENTA='\u001b[0;35m'
NC='\033[0m' 
ARROWDOWN='\u2193'
ARROWUP='\u2191'

downloadMeas1=`awk '/enp0s31f6:/ {print $2}' /proc/net/dev`
uploadMeas1=`awk '/enp0s31f6:/ {print $10}' /proc/net/dev`

arrayDownload=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
arrayUpload=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
declare avgDown
declare avgUp

main