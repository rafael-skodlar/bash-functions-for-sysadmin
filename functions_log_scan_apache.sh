# apache log related functions

log_grep_string() {
mode=$1
apache_log=$2
out_file=$3

cd $WWW_LOG_DIR
file2view=$out_file

if [ "$mode" == "-string" ]; then
    select_string
    echo -e "\n..... parse "$string" $apache_log\n"
    awk -vstring=$grep_string '{if ($7 ~ string) print $4 " " $1 " \t" $7}' $apache_log > $out_file
    grep_str=$grep_string
elif [ "$mode" == "-date" ]; then
    # silly default Apache date format
    apache_date=$(date '+%d/%b/%Y')
    mydate=$(usr_input "date " $apache_date)
    echo -e "\n..... grep $mydate $apache_log\n"
    awk -vstring=$mydate '{if ($4 ~ string) print $4 " " $1 " \t" $7}' $apache_log > $out_file
    grep_str=$mydate
elif [ "$mode" == "-ip" ]; then
    myIP=$(usr_input "IP [enter x for unique IPs]" $myIP)
    grep_str=$myIP
    if [ "$myIP" != "" ]; then
        echo -e "\n..... parse lines with IP: $myIP LOG: $apache_log\n"
        awk -vstring=$myIP '{if ($1 ~ string) print $4 " " $1 " \t" $7}' $apache_log > $out_file
    elif [ "$myIP" != "x" ]; then
        echo -e "\n..... parse unique IPs from LOG: $apache_log\n"
        awk -vstring=$myIP '{print $1}' $apache_log | sort | uniq | egrep -v "127.0.0" > $out_file
        count=1
        while read line; do
            logIP=$(echo $line | awk '{print $2}')
            rhost[$count]=$(dig -x $logIP | awk '$4 ~ /PTR/{print $5}')
            echo "$logIP[$count] $rhost[$count]"
            let count=count+1
        done < $out_file
    grep_str="unique IPs"
    fi
elif [ "$mode" == "-raw" ]; then
    file2view=$apache_log
else
    echo -e "\nusage: log_grep_string <mode> <log file> <outfile>\n\tmodes: -string -date -ip -raw\n"
fi

view_file less $file2view
last_step="grep $grep_str $apache_log"
}
