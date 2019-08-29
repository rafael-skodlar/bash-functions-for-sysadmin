# 2012-10-17 Rafael Skodlar; time related functions

mytime() {
# provide time stamp in different formats

mode=$1
mstring=$2

if [ "$mode" == "-hm" ]; then
    ts=$(date '+%H:%M')
elif [ "$mode" == "-hms" ]; then
    ts=$(date '+%H:%M:%S')
elif [ "$mode" == "-sec" ]; then
    ts=$(date '+%s')
elif [ "$mode" == "-date" ]; then
    ts=$(date '+%F')
elif [ "$mode" == "-date time" ]; then
    ts=$(date '+%F %T')
elif [ "$mode" == "-date_time" ]; then
    ts=$(date '+%F_%T')
elif [ "$mode" == "-log_time" ]; then
    ts=$(date '+%Y%m%d_%H%M%S')
elif [ "$mode" == "-i2u" -a ! -z "$mstring" ]; then    # ISO 8601 to Unix
    ts=$(date -d "${mstring}" '+%s')
elif [ "$mode" == "-u2i" -a ! -z "$mstring" ]; then      # Unix to ISO 8601
    ts=$(date -d @${mstring} '+%F %T')
else
    cat << EOM
Usage:
    $0 <mode> <time in seconds or string>
        -hm                         (HH:MM)
        -hms                        (HH:MM:SS)
        -sec                        (Unix seconds now)
        -date                       (YYYY-MM-DD)
        -date time                  (YYYY-MM-DD HH:MM:SS)
        -date_time                  (YYYY-MM-DD_HH:MM:SS)
        -log_time                   (YYYYMMDD_HHMMSS)
        -i2u 'YYYY-MM-DD HH:MM:SS'  (convert ISO 8601 to Unix seconds)
        -u2i seconds                (convert Unix seconds to YYYY-MM-DD HH:MM:SS)

EOM
fi
echo $ts
}

time_diff() {
# calculate time difference and present it in requested format:
# MODE:
# hr - human readable standard (http://en.wikipedia.org/wiki/ISO_8601)
# sec - seconds
# start and stop are in Unix seconds since the epoch (1969-12-31 16:00:00)

mode=$1
start=$2
stop=$3
usage="\nUsage: time_diff <mode> [ <start time> | <stop time> ]\n\t-hr <start time> [<stop time>]\t(time difference: HH:MM:SS)\n\t-s <start time> [<stop time>]\t(time difference in seconds)\n\nTime now [Unix seconds]: $(date '+%s')\n"

if [ $# -lt 2 ]; then
    echo -e "undefined start time\n$usage"
else
    if [ -z "$stop" ]; then
        stop=$(date '+%s')
    fi

    let diff_seconds=stop-start

    if [ "$mode" == "-hr" ]; then
        days=$(($diff_seconds / 86400))
        reminder_d=$(($diff_seconds % 86400))
        hours=$(($reminder_d / 3600))
        reminder_h=$(($reminder_d % 3600))
        minutes=$(($reminder_h / 60))
        seconds=$(($reminder_h % 60))

        if [ $diff_seconds -ge 86400 ];then
            printf '%s days, %02d:%02d:%02d HH:MM:SS\n' $days $hours $minutes $seconds
        else
            printf '%02d:%02d:%02d HH:MM:SS\n' $hours $minutes $seconds
        fi
    elif [ "$mode" == "-s" ]; then
        echo $diff_seconds
    else
        echo -e $usage
    fi
fi
}

timed_run() {
# mode: 0 - quiet, 1- time stamp, 2 - spinner
# time_limit in seconds
# process to run

mode=$1
time_limit=$2
process=$3

$process &

count=0
while [ $count -lt $time_limit ]
do
    sleep 1
    let count=count+1
    if [ "$mode" == "1" ]; then
        mytime -hms
    elif [ "$mode" == "2" ]; then
        spinner $(mytime -hms)
    fi
done
}

dow() {
# show or select day of the week
mode=$1
if [ "$mode" == 'select' ]; then
    DAYS="Mon Tue Wed Thu Fri Sat Sun"
    declare -a weekdays
    select day in $DAYS
    do
        echo $day
        break
    done
else
    echo $(date -d '+%${mode}' | awk '{print $1}')
fi
}
