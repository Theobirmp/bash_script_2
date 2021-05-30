#! /bin/bash

#./create_infiles.sh inputFile input_dir numFilesPerDirectory

input_file=$1
input_dir=$2
num_files_per_dir=$3


#creates the folder with the given name if it doesnt exist
if [ -d "$input_dir" ]
then
    echo "$input_dir exists "  
else
    echo "creating the directory ..."
    mkdir -p "$input_dir"
    countries_array=()

    while read line 
    do
        array=($line)
        countries_array+=(${array[3]}) #we have all the countries (duolicates included)
    done < "$input_file"

    unique_countries=($(echo "${countries_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')) #keeps the unique countries
    #echo ${unique_countries[@]} #print for good measure
    cd "$input_dir"
    for((i=0;i<${#unique_countries[@]};i++));   #for each country
    do
        mkdir -p "${unique_countries[$i]}"      #make the directory of the country
        cd "${unique_countries[$i]}"
        for (( num=1; num<=num_files_per_dir; num++ ))
        do 
        touch ${unique_countries[$i]}$num     #make the appropriate number of txt files of the given country
        
        done
        cd ..
    done
    
    for i in "${unique_countries[@]}"; do rr_array+=(1); done   #create an array of ones - same size as the size of the unique country array
                                                                #unique country and rr_array form a kind of dictionary (as in python)
                                                                #e.g. if the country in pos 3 is Spain(countries array) then in the rr_array
                                                                #the third one is a counter relative to Spain
    cd ..       #cds are used to get to the appopriate path,no need for full path
    while read line 
    do
        array=($line)
        curr_country=(${array[3]}) #the country of each record
        for i in "${!unique_countries[@]}"; do  #this function returns the position of the given country-this is used to relate the two arrays
            if [[ "${unique_countries[$i]}" = "${curr_country}" ]]; then
                rr_pos_finder="${i}";
            fi
        done
        #insert the record to the appropriate file
        cd "$input_dir" #go in the directory
        cd "$curr_country" #go to the directory
        echo "${array[*]}" >> "$curr_country""${rr_array[$rr_pos_finder]}"
        (( rr_array[$rr_pos_finder]++ ))    #increase the counter for the country we found
        if [ ${rr_array[$rr_pos_finder]} -gt $((num_files_per_dir)) ]   #if we exceed the number of files we reset the counter
        then
            rr_array[$rr_pos_finder]=1
        fi
        cd ..   #cds for reaching the appropriate file
        cd ..
        
    done < "$input_file"
fi    