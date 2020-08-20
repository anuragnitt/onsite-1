#!/bin/bash

declare -A fields

for count in {1..5}
do
	v=($(awk '{if(NR==1) print $0}' ./final.log | awk -v var="$count" -F'[\t]+' '{print $var}'))
	fields+=([$v]=$count)
done

echo -e '\nSearch field and search query should be delimited by a ":"'
echo -e 'Enter "Q" to exit\n'

while true
do	
	echo -e '\n'
	read -p 'Search query -> ' query
	
	if [ $query == 'Q' ] || [ $query == 'q' ]
	then
		exit
	fi
	
	field=$(echo $query | cut -d ':' -f 1)
	value=$(echo $query | cut -d ':' -f 2)
	
	valid=false
	for x in "${!fields[@]}"
	do
		if [[ $(echo ${x^^*}) == *"$(echo ${field^^*})"* ]] || [[ $(echo ${x,,*}) == *"$(echo ${field,,*})"* ]]
		then
			valid=${fields[$x]}
			break
		fi
	done
	
	if [ $valid = false ]
	then
		echo -e 'Invalid query\n'
		continue
	else
		n_lines=$(wc -l ./final.log | cut -d ' ' -f 1)
		n_printed=0
		
		for count in $(seq 2 $n_lines)
		do
			real_value=$(awk -v var1="$count" '{if(NR==var1) print $0}' ./final.log | awk -v var2="$valid" -F'[\t]+' '{print $var2}')
			if [[ $(echo ${real_value^^*}) == "$(echo ${value^^*})"* ]] || [[ $(echo ${real_value^^*}) == "$(echo ${value,,*})"* ]]
			then
				echo -e "\nRow-$count:" $(awk -v var="$count" '{if(NR==var) print $0}' ./final.log)
				((n_printed++))
			fi
		done
		
		if [ $n_printed -eq 0 ]
		then
			echo -e 'No match found :/\n'
		fi
	fi
done
