# 2012-09-27 Rafael Skodlar; collected and created a number of reusable functions for use in scripts
# 2012-09-27 Rafael Skodlar; updated functions
# 2012-10-17 Rafael Skodlar; broke related functions into separate files

functionsSysadminVersion=1.0

std_lables() {
# Standard lables used in scripts
# Note: parsing in some scripts using this fuction and make_line() depends on the
# following strings listed in order of priority from top to bottom; quotes excluded

ABORT="Aborting:"
NOTE="Note:"
WARN="Warning:"
MISSING="Missing:"
ERROR="Error:"
}

usr_input() {
# user input; return an answer or default
# mode '-n' for normal prompt
# purpose of mode is mainly '-s' (silent) for asking passwords; see man bash for read

inputMode=$1
question="$2"
default=""

if [ $# -gt 2 ]; then
    default=$3
fi

if [ "$inputMode" == "-n" ]; then
    if [ "$default" != "" ]; then
        read -p "$question [$default]? " answer
    else
        read -p "$question " answer
    fi
    if [ "$answer" == "" ]; then
        answer=$default
    fi
elif [ "$inputMode" == "-s" ]; then     # silent, no echo for password
    read -s -p "$question? " answer
fi
echo $answer
}

select_file() {
# select from all or from types of files in a directory
# file names modes:
# -pre == prefix
# -ext == extension
# -pat == pattern

local mydir
local mode

mode=$1
mydir=$2
fileType=$3

if [ $# -lt 2 ]; then
    echo -e "missing or bad parameters\n"
    return
fi

if [ ! -d $mydir ]; then
    echo -e "no such directory: $mydir\n"
    return
fi

cd $mydir

if [ "$mode" == "-pre" ]; then
    fileList=$(ls -p ${fileType}* | grep -v '/')
elif [ "$mode" == "-ext" ]; then
    fileList=$(ls -p *${fileType} | grep -v '/')
elif [ "$mode" == "-pat" ]; then
    fileList=$(ls -p *${fileType}* | grep -v '/')
elif [ "$mode" == "-all" ]; then
    fileList=$(ls -p | grep -v '/')
fi

select file in $fileList
do
    echo $file
    break
done
}

# network functions
mping() {
local t="$1"
local _ping="/bin/ping"
local c=$(parse_url "$t")
[ "$t" != "$c" ] && echo "Sending ICMP ECHO_REQUEST to \"$c\"..."
$_ping $c
}

my_log() {
# ===== logging
logMode=$1
logFile=$2
logEntry=$3
logTime=$(mytime -date_time)

if [ "$logMode" == "-n" ]; then     # normal
    echo -e "$logTime $logEntry" >> $logFile
elif [ "$logMode" == "-e" ]; then   # error
    echo -e "$logTime error: $logEntry" >> $logFile
elif [ "$logMode" == "-r" ]; then   # rotate log file
    if [ -e $logFile ]; then
        mv $logFile ${logFile}_${logTime}
    else
        echo -e "$ERROR no such file $logFile"
    fi
fi
}

my_image() {
myScript="/tmp/make_image_$(whoami).sh"
myImage="/tmp/image_$(whoami).png"

cat << EOM > $myScript
archive=$(awk '/^__imageBlob__/{print NR + 1;exit;0;}' $0)
tail -n+$archive > $myImage
display $myImage
rm $myImage
exit
__imageBlob__
EOM
}

my_print() {
# ===== adjusted and colorized print on screen
# modes: left, center, right
# under construction
mode=$1
color=$2
text=$3

if [ "$mode" == "left" ]; then
    printf "%s" $text
elif [ "$mode" == "center" ]; then
    printf "%*s" $(((${#text}+$COLUMNS)/2)) "$text"
elif [ "$mode" == "right" ]; then
    printf "%*s" $($COLUMNS-${#text}) "$text"
fi

colors="red green blue yellow"
declare -a colorMap
colorMap['red']="\e[0;35m"
color_reset="\e[0m"
precolor=colorMap[$1]

echo -e "${precolor}${myout}${postcolor}"
}

sub_process_status() {
# under construction

if [ $? -ne 0 ]; then
     echo "ERROR found in: ls -al $1"
#     let "errorCounter = errorCounter + 1"
fi
}

calc() {
#CLI calculator
echo "${1}" | bc -l;
}

myfun() {
function_files="$(ls ~/bin/functions_*.sh)"
echo -e "\n\t***** available functions:"
for funct in $function_files
do
    echo -e "\n$funct:"
    awk -F\( '/\(\) {/{print "    " $1}' $funct
done
}

check_port() {
# check if port is open
server=$(usr_input server); port=$(usr_input port); proto=$(usr_input protocol tcp)
port=$(usr_input port)
proto=$(usr_input protocol tcp)
echo
exec 5<>/dev/${proto}/${server}/${port}
(( $? == 0 )) && exec 5<&-
}

view_file() {
# view information file

if [ $# -lt 2 ]; then
    echo -e "\nUSAGE: view_file [less|grep ] <file> <grep string>\n"
    return
else
    mode=$1
    myfile=$2
    opt1=$3
fi

if [ ! -e $myfile ]; then
    echo "$MISSING $myfile"
fi

if [ "$mode" == "less" ]; then
    less $myfile
elif [ "$mode" == "grep" ]; then
    grep $opt1 $myfile | less
elif [ "$mode" == "hex" ]; then
    hexdump -C $myfile | less
fi
}

mklink() {
# ===== make short or long link
linktype=$1
srcfile=$2
workdir=$3
dstfile=$4

if [ -e $srcfile ]; then
    if [ "$linktype" == "-s" ]; then    # short link
        cd $workdir
        ln -s $srcfile .
    elif [ "$linktype" == "-l" ]; then  # long (absolute) )link
        ln -s ${workdir}/${srcfile} $dstfile
    fi
else
    echo "no such file: $srcfile"
fi
}

mkseq() {
mode=$1
seqFirst=$2
seqIncr=$3
seqLast=$4
string=$5
task=$6

if [ "$mode" == "num" ]; then
    for seq in $(seq $seqFirst $seqIncr $seqLast)
    do
        echo "$seq"
    done
elif [ "$mode" == "printf" ]; then
    for seq in $(seq $seqFirst $seqIncr $seqLast)
    do
        printf "%d " $seq
    done
elif [ "$mode" == "_str" ]; then
    for seq in $(seq $seqFirst $seqIncr $seqLast)
    do
        printf "%s%d " $string $seq
    done
elif [ "$mode" == "str_" ]; then
    for seq in $(seq $seqFirst $seqIncr $seqLast)
    do
        printf "%d%s " $seq $string
    done
elif [ "$mode" == "-h" -o "$mode" == "" ]; then
    echo -e "\nFunction use:\n    myseq <mode> <first> <increment> <last> <string>\n\tmode: echo, pr
intf, [_str|str_]\n\tEx.: myseq str_ 11 2 22 my_string\nmodes: num printf _str str_\n"
fi
}

make_pack() {
# create a package for use elsewhere
# package will install files under $HOME/bin
# pack files list: full file path relative to $HOME directory; it may contain comments

USAGE="pack_utility -tar <pack files list (absolute path)> <pack name> <pack version> [dst_dir]"
packType=$1
packFilesList=$2
pname=$3
pack_version=$4
dst_dir=${5:-${HOME}/tmp/$pname}
logFile=${dst_dir}/mkpack_${pname}.log

[ -e $logFile ] && rm $logFile

if [ $# -lt 4 ]; then
    echo -e "Usage:\n\t$USAGE"
    return
fi

if [ ! -d ${dst_dir}/bin ]; then
    mkdir -p ${dst_dir}/bin
else
    rm -f ${dst_dir}/bin/*
fi

if [ "$packType" == "-tar" ]; then
    pack_name="${dst_dir}/${pname}-${pack_version}.tar"
    [ -e $pack_name ] && rm $pack_name
    echo -e "\n----- creating installation pack:\n\t$pack_name"
    while read pack_file
    do
        [ -z "${pack_file%%#*}" ] && continue   # skip commented or empty lines
        echo -e "..... cp -rp $pack_file ${dst_dir}/bin" | tee $logFile
        cp -rp $pack_file ${dst_dir}/bin
        if [ $? -ne 0 ]; then
            echo -e "$ERROR while copying $pack_file\n"
            #return 1
        fi
    done < $packFilesList
    if [ "$FUNCTIONS" != "" ]; then     # FUNCTIONS is defined in the application
        for funct in $FUNCTIONS
        do
            cp $funct ${dst_dir}/bin
        done
    fi
    cd $dst_dir
    tar cvf $pack_name bin 2>&1 >> $logFile
else
    echo $usage
fi
echo -e "\n----- pack creation complete:\n$(ls -lh $pack_name)\n  LOG: $logFile\n"
}

make_line() {
local size=$1
local lineString="$2"
local lstring=""

if [ "$size" -lt 1 ]; then
    echo -e "usage: make_line $size $lineString"
    return
fi

for myseq in $(seq $size)
do
    if [ "$lineString" == "" ]; then
        lstring="${lstring} "
    else
        lstring="${lstring}${lineString}"
    fi
done
printf "%s" $lstring
}

application_lock(){
# lock application to prevent running two identical sessions at the same time, also unlock
# if locked, watch for number of seconds and return to caller

mode=$1
lockFile=$2

if [ $mode == "lock" ]; then
    echo "$$ $(date '+%F %T') $(whoami)" > $lockFile
elif [ $mode == "check" ]; then
    wait_time=$3
    count_limit=3
    lcount=0
    let wait_time_max=wait_time*count_limit

    while [ -e $app_lock ]
    do
        echo -e "$WARN lock file exists. Wait for $wait_time_max seconds.\n    Remove $app_lock manually if the file does not go away:\nrm $app_lock"
        sleep $wait_time
        if [ $lcount -eq 3 ]; then
            echo -e "$NOTE lock file:\n"
            cat $app_lock
            exit 1
        fi
        let lcount=lcount+1
    done
elif [ $mode == "unlock" ]; then
    rm $lockFile
fi
}

file_ownership() {
# change files ownership based on info in the configuration file
# file format; standard bash comment lines permitted
# owner:group:permissions:<relative path>/<file name>
# permissions in octal (750, 644, 775)

conf_file=$1
while read line
do
    [ -z "${line%%#*}" ] && continue   # skip comment or empty lines
    owner=$(echo $line | awk -F: '{print $1}')
    group=$(echo $line | awk -F: '{print $2}')
    permissions=$(echo $line | awk -F: '{print $3}')
    file=$(echo $line | awk -F: '{print $4}')
    chown $owner:$group $file
    chmod $permissions $file
done < $conf_file
}

string_replace() {
# replace a string in a file with another string
filename=$1
string1=$2
string2=$3

cp $filename $filename.$$
sed "s/$string1/$string2/g" $filename > $filename.$$
[ -e $filename.$$ ] && mv $filename.$$ $filename
if [ -e $filename ]; then
    echo -e "$ERROR failed to parse from $filename to $filename.$$ and rename it to it's original."
fi
}

is_digit() {
# Tests whether *entire string* is numerical.
if [ $# -ne 1 ]; then
    echo 1
    return 1
fi
case $1 in
  *[!0-9]*|"") echo 1;;
            *) echo 0;;
esac
}

debug() {
# help debugging shell scripts
# modes: write2file, view, grep_log

LINE=">>>>>"
USAGE="usage: debug mode <filename> <message>\n\tmodes: write2file, view, grep_log"
if [ $# -lt 2 ]; then
    echo -e "$USAGE"
    return
else
    debug_mode=$1
    debug_file=$2
    debug_message=$3
fi

echo -e "\n$LINE DEBUG start\n   mode: $debug_mode\n   file: $debug_file\nmessage: $debug_message"
if [ "$debug_mode" == "write2file" ]; then
    echo -e "$debug_message" >> $debug_file
elif [ "$debug_mode" == "view" ]; then
    view_file less $debug_file
elif [ "$debug_mode" == "grep" ]; then
    grep "$debug_message" $debug_file
else
    echo -e "$LINE no such mode: $debug_mode\n$USAGE"
fi
echo -e "\n$LINE DEBUG stop\n"
}

is_ipv4() {
myip=$1

if [[ $myip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
   IFS=.
    set $myip
    for quad in 1 2 3 4; do
        if eval [ \$$quad -gt 255 ]; then
            echo "bad [$quad]"
            return 1
        fi
    done
    # yes, it's IP
    echo "yes"
else
    echo "no"
fi
}
