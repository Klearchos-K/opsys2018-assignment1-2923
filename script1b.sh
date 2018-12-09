#!/bin/bash

#fuction that ckech a single site
checksite(){
	now_hash=$(wget $1 -O- -q | md5sum | cut -f1 -d' ') #calculate the hash
	exists=false
	i=0
	for s in ${site_exists[@]}
	do
		if [ $s == $1 ]
		then
			exists=true
			h=${md5[i]} #take the current hash
		break
		fi
		((i++))
	done
	#check if dowloaded ok
	if [ $now_hash == d41d8cd98f00b204e9800998ecf8427e ] #hash of null string
	then
		if [ $exists == true ]
		then 
			echo $1 >> output.txt 
			echo $now_hash >> output.txt
		fi
		(>&2 echo $1 FAILED)
		return
	fi

	if [ $exists == true ]
	then
		if [ $h != $now_hash ]
		then
			md5[i]=$now_hash
			echo $1
		fi
	else
		echo $1 INIT
	fi
	echo $1 >> output.txt 
	echo $now_hash >> output.txt


}

filename="$1"
#store sites in an array
i=0
while read -r line
do
	name="$line"
	if [[ $name != \#* ]]
	then 
		site[i]="$name"
		((i++))
	fi
done < "$filename"

#read previous situation stored in output.txt
i=0
j=0
k=0
while read -r line
do
	name="$line"
	if [ $(($i % 2)) == 0 ]
	then
		site_exists[j]="$name"
		((j++))
	else
		md5[k]="$name"
		((k++))
	fi
	((i++))
done < "output.txt"

echo -n "" > output.txt


#check each site
h=fooooo
for j in ${site[@]}
do
	checksite $j &

done
wait


#dont miss to store results for sites that was visited before but arent ask to ckeck now
i=0
for j in ${site_exists[@]}
do
	exists=false
	for s in ${site[@]}
	do
		if [ $s == $j ]
		then
			exists=true
			h=${md5[i]}
		break
		fi
		
	done
	if [ $exists == false ]
	then
		echo ${site_exists[i]} >> output.txt
		echo ${md5[i]} >> output.txt
		echo brr
	fi
	((i++))
done




