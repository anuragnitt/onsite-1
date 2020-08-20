#!/bin/bash

download () {
	name=$(echo "$1" | cut -d '/' -f 5)
	wget $1
	link=$(cat $name | grep 'cdn-' | cut -d '"' -f 2)
	wget $link
	rm $name
}
url='https://anonfiles.com/3bh1Q0N7o6/text_files.tar_xz'
download $url
tar -xvf ./text_files.tar.xz
rm ./text_files.tar.xz

name=0
email=0
branch=0
roll=0
grad=0

for file_num in 1 2 3
do
	for count in 1 2 3
	do
		field=$(awk '{if(NR==1) print $0}' ./file_$file_num.log | awk -v var="$count" -F'[\t]+' '{print $var}')
		
		case $field in
			NAME)
				if [ $name -eq 0 ]
				then
					name=($file_num $count)
				fi
				;;
			
			EMAIL)
				if [ $email -eq 0 ]
				then
					email=($file_num $count)
				fi
				;;
			
			BRANCH)
				if [ $branch -eq 0 ]
				then
					branch=($file_num $count)
				fi
				;;
				
			ROLLNUMBER)
				if [ $roll -eq 0 ]
				then
					roll=($file_num $count)
				fi
				;;
				
			GRADYEAR)
				if [ $grad -eq 0 ]
				then
					grad=($file_num $count)
				fi
				;;
		esac
	done
done

touch ./final.log
chmod 777 ./final.log
echo -e "NAME\t\t\tEMAIL\t\t\t\tBRANCH\t\t\tROLLNUMBER\t\tGRADYEAR" > ./final.log

n_lines=$(wc -l ./file_1.log | cut -d ' ' -f 1)
for count in $(seq 2 $n_lines)
do
	NAME=$(awk -v var1="$count" '{if(NR==var1) print $0}' ./file_${name[0]}.log | awk -v var2="${name[1]}" -F'[\t]+' '{print $var2}')
	EMAIL=$(awk -v var1="$count" '{if(NR==var1) print $0}' ./file_${email[0]}.log | awk -v var2="${email[1]}" -F'[\t]+' '{print $var2}')
	BRANCH=$(awk -v var1="$count" '{if(NR==var1) print $0}' ./file_${branch[0]}.log | awk -v var2="${branch[1]}" -F'[\t]+' '{print $var2}')
	ROLLNUMBER=$(awk -v var1="$count" '{if(NR==var1) print $0}' ./file_${roll[0]}.log | awk -v var2="${roll[1]}" -F'[\t]+' '{print $var2}')
	GRADYEAR=$(awk -v var1="$count" '{if(NR==var1) print $0}' ./file_${grad[0]}.log | awk -v var2="${grad[1]}" -F'[\t]+' '{print $var2}')
	
	echo -e "$NAME\t\t$EMAIL\t\t$BRANCH\t\t$ROLLNUMBER\t\t$GRADYEAR" >> ./final.log
done
