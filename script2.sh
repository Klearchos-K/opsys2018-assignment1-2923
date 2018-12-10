#!/bin/bash

filename="$1"
mkdir txts >/dev/null 2>&1 #folder to untar
tar xf $filename -C "./txts" >/dev/null 2>&1
if [ $? != 0 ]; then
	echo "tar file not found, please place it in same folder as the script"
fi
i=0
#rm -rf assignments
mkdir assignments >/dev/null 2>&1
find ./txts -name '*.txt' | while read -r line; do #for each txt in tar
	while read url; do #for each url in single txt
		if [[ $url != https* ]]; then
			continue

		fi
 		repo_name=$(echo $url | awk  -F "/" '{print $NF}')
		git clone -q "$url" "assignments/$repo_name" >/dev/null 2>&1
		if [ $? = 0 ]; then
			echo $url: Cloning OK 
			((i++))
		else
			echo $url: Cloning FAILED>&2
		fi
		break #go to next file

	done < "$line"


done

ls ./assignments | while read -r rep; do #for each repo
	echo $rep":"
	d=$(find ./assignments/$rep -type d -not -path "./assignments/$rep/.git/*"| wc -l)
	t=$(find ./assignments/$rep -name "*.txt" -not -path "./assignments/$rep/.git/*" | wc -l)
	all=$(find ./assignments/$rep -type f -not -path "./assignments/$rep/.git/*" | wc -l)
	o=$(expr $all - $t)
	echo "Number of directories: " $(expr $d - 2)
	echo "Number of txt files: " $t
	echo "Number of other files: " $o
	
	#check if txts and folder exists
	ok=true
	find ./assignments/$rep -name "dataA.txt" -maxdepth 1 >/dev/null 2>&1
	if [ $? != 0 ];then
		ok=false
	fi
	if [ ! -d "./assignments/$rep/more" ];then
		ok=false
	else
		find ./assignments/$rep/more -name "dataB.txt" -maxdepth 1 >/dev/null 2>&1
		if [ $? != 0 ];then
			ok=false
		fi
		find ./assignments/$rep/more -name "dataC.txt" -maxdepth 1 >/dev/null 2>&1
		if [ $? != 0 ];then
			ok=false
		fi
	fi

	#required files exists so check if they are not other files
	if [ $ok = true ] && [ $(expr $d - 2) = 1 ] && [ $t = 3 ] && [ $o = 0 ]; then
		echo "Directory structure is OK"
	else
		echo "Directory structure in NOT OK"
	
	fi

done

rm -rf assignments
rm -rf txts
