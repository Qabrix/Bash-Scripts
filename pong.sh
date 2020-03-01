paddle1=("█")
paddle2=("█")
space=" "

w=$(tput cols)
h=$(tput lines)
startx=`echo "$w/2" | bc`
starty=`echo "$h/2" | bc`

ballx=$startx
bally=$starty
vel_x=1
vel_y=-1
max_speed=2

position1x=3
position2x=$(( $w-2 ))
position1y=$(( $h-5 ))
position2y=$(( $h-5 ))

paddle1Pos=1
paddle2Pos=1
len=6

draw_paddle1() {
  erase=$position1y
  for ((i=0; i<len; i++)) {
    echo -en "\033[${erase};${position1x}H$space"
    erase=$(( $erase-1 ))
  }
  (( position1y += $1 ))
  (( position1y = position1y > h ? h : position1y < len ? len : position1y  ))
  height=$position1y
  for ((i=0; i<len; i++)); do
    echo -en "\033[${height};${position1x}H$paddle1"
    height=$(($height-1))
  done
}

draw_paddle2() {
  erase=$position2y
  for ((i=0; i<len; i++)) {
    echo -en "\033[${erase};${position2x}H$space"
    erase=$(($erase-1))
  }
  (( position2y += $1 ))
  (( position2y = position2y > h ? h : position2y < len ? len : position2y  ))
  height=$position2y
  for ((i=0; i<len; i++)); do
    echo -en "\033[${height};${position2x}H$paddle2"
    height=$(($height-1))
  done
}
tput civis
tput clear
clear

draw_paddle1 1;
draw_paddle2 1;

while [[ $q != q ]]; do
  echo -en "\033[${bally};${ballx}H "
  (( ballx += vel_x ))
  (( bally += vel_y ))
  echo -en "\033[${bally};${ballx}H●"
  read -n 1 -s -t 0.05 q
  case "$q" in
    [wW] ) draw_paddle1 -2;;
    [sS] ) draw_paddle1 2;;
    [iI] ) draw_paddle2 -2;;
    [kK] ) draw_paddle2 2;;
  esac

  (( ballx >= position2x - 1 || ballx <= position1x + 1 )) && (( vel_x = - vel_x ))
    (( bally + vel_y < 1 )) && echo -en "\033[${bally};${ballx}H " && (( bally = 1 - bally - vel_y )) && (( vel_y = - vel_y )) && 
        echo -en "\033[${bally};${ballx}H●"
    (( bally + vel_y > h )) && echo -en "\033[${bally};${ballx}H " && (( bally = 2*h - 1 - bally - vel_y )) && (( vel_y = - vel_y  )) && 
        echo -en "\033[${bally};${ballx}H●"

  if (( ballx <= position1x + 1 )); then
    if (( bally <= position1y && bally >= position1y - len  )); then
      (( vel_y = bally - (position1y - len) - len/2 ))
      (( ${vel_y//-/} > max_speed )) && 
        vel_y=${vel-y//[0-9]*/$max_speed}
    else
      echo -en "\033[${bally};${ballx}H "
      ballx=$startx
      bally=$starty
      vel_y=$(( RANDOM % max_speed + 1))
      vell_x=1
    fi
  fi

  if (( ballx >= position2x - 1 )); then
    if (( bally <= position2y && bally >= position2y - len  )); then
      (( vel_y = bally - (position2y - len) - len/2 ))
      (( ${vel_y//-/} > max_speed )) && 
        vel_y=${vel-y//[0-9]*/$max_speed}
    else
      echo -en "\033[${bally};${ballx}H "
      ballx=$startx
      bally=$starty
      vel_y=$(( RANDOM % max_speed + 1))
      vell_x=-1
    fi
  fi

done
tput clear
tput cnorm