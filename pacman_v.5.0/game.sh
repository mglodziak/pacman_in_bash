#!/bin/bash

var_width_game=52
var_height_game=22
var_width_game_half=$[$var_width_game/2]
var_height_game_half=$[$var_height_game/2]
var_score=0

var_position_x=0 #player position
var_position_y=0

var_number_of_monsters=$1

for (( i=1; $i<=$var_number_of_monsters; i++ )); do
tab_monster_position_x[$i]=0 #monster positions
tab_monster_position_y[$i]=0
tab_eat_count_move[$i]=1
tab_eat_move_direction[$i]=0

done

var_number_of_eats=$2

for (( i=1; $i<=$var_number_of_eats; i++ )); do
tab_eat_position_x[$i]=0 #eat positions
tab_eat_position_y[$i]=0
#tab_eat_count_move[$i]=1
#tab_eat_move_direction[$i]=0
done


var_random_x=0
var_random_y=0

var_random_to_move=0



function make_place {
	
	rm place
	touch place
	for (( i=1;$i<=$var_height_game;i++ )); do
		  for (( j=1; $j<=$var_width_game; j++ )); do
			  if [[ $i -eq 1 || $j -eq 1 || $j -eq $var_width_game  || $i -eq $var_height_game ]]; then
				 printf "X"  >> place
		  else
				 printf " " >> place
			  fi
		  done
		  printf '\n' >> place
		done
}

function show_place {
	echo -e "\n\n\n\n\n"
	printf "\t\t     Score: $var_score\n\n"
cat place
  }


  function set_player_start_point {

var_start_x=$1
var_start_y=$2
var_object=$3
var_position_x=$var_start_x
var_position_y=$var_start_y

	   gawk -v start_y="$var_start_y"\
		 -v start_x="$var_start_x"\
		  -v height="$var_height_game"\
		   -v object="$var_object"\
		  -i inplace -F "" 'BEGINFILE{NF=height; OFS=""} {if(NR==start_y) {$start_x=object} {print $0}}' place
  }

function end_game {
	echo -e "\n"
	printf "\t\t Game over!\n\n "
	printf "\t"
	read -p "Enter your name: " name
	date=`date +"%H:%M  %d.%m.%y"`
	echo -e "$name \t $var_score \t $date" >> best_scores.txt

./start.sh
exit
}

function delete_old_P {
         gawk -v x="$1"\
                 -v y="$2"\
		   -v height="$var_height_game"\
		    -i inplace -F "" 'BEGINFILE{NF=height; OFS=""} {if(NR==y) {$x=" "} {print $0}}' place

}


function set_new_P {
 	 gawk -v x="$1"\
                 -v y="$2"\
		  -v object=$3\
                   -v height="$var_height_game"\
                  -i inplace -F "" 'BEGINFILE{NF=height; OFS=""} {if(NR==y) {$x=object} {print $0}}' place

}



function move_player {
if [[ $var_position_x -eq 1 ||\
       	$var_position_y -eq 1 ||\
       	$var_position_x -eq $var_width_game  ||\
       	$var_position_y -eq $var_height_game ]]; 
then
        end_game

else
	read -t 0.1 -n 1 key

if [[ ! -z $key ]]; then
key2=$key
fi

	case $key2 in
	
	w|W) delete_old_P $var_position_x $var_position_y
                var_position_y=$[$var_position_y-1]
                set_new_P $var_position_x $var_position_y '@' ;;
	
	a|A) delete_old_P $var_position_x $var_position_y
                var_position_x=$[$var_position_x-1]
                set_new_P $var_position_x $var_position_y '@' ;;

	s|S) delete_old_P $var_position_x $var_position_y
                var_position_y=$[$var_position_y+1]
                set_new_P $var_position_x $var_position_y '@' ;;

	d|D) delete_old_P $var_position_x $var_position_y 
		var_position_x=$[$var_position_x+1]
		set_new_P $var_position_x $var_position_y '@' ;;
	
	*) move_player	;;

	esac

fi

}


function random_xy_generator {
var_random_x=$(( $RANDOM % $[$var_width_game-2] + 2 ))
var_random_y=$(( $RANDOM % $[$var_height_game-2] + 2 ))
}


function random_xy {
	for (( i=1; $i<=$var_number_of_monsters; i++ )); do

	random_xy_generator
while [[ 1 ]]; do
if [[ $var_random_x -gt 23 && $var_random_x -lt 29 && $var_random_y -gt 8 && $var_random_y -lt 14 ]]; then
	random_xy_generator

else

tab_monster_position_x[$i]=$var_random_x
tab_monster_position_y[$i]=$var_random_y
break
fi
done

done
}



 function set_monster_start_point {
for (( i=1; $i<=$var_number_of_monsters; i++ )); do

random_xy
var_start_x=${tab_monster_position_x[$i]}
var_start_y=${tab_monster_position_y[$i]}
var_object=$1

           gawk -v start_y="$var_start_y"\
                 -v start_x="$var_start_x"\
                  -v height="$var_height_game"\
                   -v object="$var_object"\
                  -i inplace -F "" 'BEGINFILE{NF=height; OFS=""} {if(NR==start_y) {$start_x=object} {print $0}}' place

   done
  }


function is_kill {
	for (( i=1; $i<=$var_number_of_monsters; i++ )); do

if [[ $var_position_x -eq ${tab_monster_position_x[$i]} && $var_position_y -eq ${tab_monster_position_y[$i]} ]]; then
        gawk -i inplace -F "" 'OFS="" { for(i=1;i<=NF;i++) {if($i=="o") $i=" "}} {print $0}' place
	clear
	show_place
	end_game
fi
done
}


function move_monsters {

	for (( i=1; $i<=$var_number_of_monsters; i++ )); do

		if [[ ${tab_monster_count_move[$i]} -eq 0 ]]; then
			tab_monster_count_move[$i]=$(( $RANDOM % 4 + 1))
			tab_monster_move_direction[$i]=$(( RANDOM % 4 ))
		fi

	case ${tab_monster_move_direction[$i]} in

        0) delete_old_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]}
		if [[ ${tab_monster_position_y[$i]} -gt 2 ]]; then
                tab_monster_position_y[$i]=$[${tab_monster_position_y[$i]}-1]
		fi
                set_new_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]} 'x'
		tab_monster_count_move[$i]=$[${tab_monster_count_move[$i]}-1];;

	1) delete_old_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]}
                if [[ ${tab_monster_position_x[$i]} -gt 2 ]]; then
                tab_monster_position_x[$i]=$[${tab_monster_position_x[$i]}-1]
                fi
                set_new_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]} 'x'
		tab_monster_count_move[$i]=$[${tab_monster_count_move[$i]}-1];;

	2) delete_old_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]}
                if [[ ${tab_monster_position_y[$i]} -lt 21 ]]; then
                tab_monster_position_y[$i]=$[${tab_monster_position_y[$i]}+1]
                fi
                set_new_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]} 'x'
		tab_monster_count_move[$i]=$[${tab_monster_count_move[$i]}-1];;
		
	3) delete_old_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]}
                if [[ ${tab_monster_position_x[$i]} -lt 51 ]]; then
                tab_monster_position_x[$i]=$[${tab_monster_position_x[$i]}+1]
                fi
                set_new_P ${tab_monster_position_x[$i]} ${tab_monster_position_y[$i]} 'x'
		tab_monster_count_move[$i]=$[${tab_monster_count_move[$i]}-1];;
        esac
done
}

function random_eat_xy {
        for (( i=1; $i<=$var_number_of_eats; i++ )); do

        random_xy_generator
while [[ 1 ]]; do
if [[ $var_random_x -gt 23 && $var_random_x -lt 29 && $var_random_y -gt 8 && $var_random_y -lt 14 ]]; then
        random_xy_generator

else

tab_eat_position_x[$i]=$var_random_x
tab_eat_position_y[$i]=$var_random_y
break
fi
done

done
}

  function set_eat_start_points {
for (( i=1; $i<=$var_number_of_eats; i++ )); do

random_eat_xy
var_start_x=${tab_eat_position_x[$i]}
var_start_y=${tab_eat_position_y[$i]}
var_object=$1

           gawk -v start_y="$var_start_y"\
                 -v start_x="$var_start_x"\
                  -v height="$var_height_game"\
                   -v object="$var_object"\
                  -i inplace -F "" 'BEGINFILE{NF=height; OFS=""} {if(NR==start_y) {$start_x=object} {print $0}}' place

   done
  }


function stay_eats {
for (( i=1; $i<=$var_number_of_eats; i++ )); do
 set_new_P ${tab_eat_position_x[$i]} ${tab_eat_position_y[$i]} 'o'
done
}

function is_eaten {
for (( i=1; $i<=$var_number_of_eats; i++ )); do

	
	if [[ $var_position_x -eq ${tab_eat_position_x[$i]} && $var_position_y -eq ${tab_eat_position_y[$i]} ]]; then
	
	var_score=$[$var_score+$var_number_of_monsters]	
	random_xy_generator
	tab_eat_position_x[$i]=$var_random_x
	tab_eat_position_y[$i]=$var_random_y

	
	fi
	done
}

#--------------------------
function game {

  make_place
  set_player_start_point $var_width_game_half $var_height_game_half '@'
  set_monster_start_point 'x'
  set_eat_start_points 'x'
  while [[ 1 ]]; do
  is_kill
  move_player
  is_eaten
  stay_eats
  is_kill
  move_monsters
  is_kill
  clear
  show_place
  done

  }

  game
