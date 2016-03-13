# 2012-09-27 Rafael Skodlar; collected and created a number of reusable functions for use in scripts
# 2012-09-27 Rafael Skodlar; updated functions
# 2012-10-17 Rafael Skodlar; broke related functions into separate files

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
question=$1
if [ $# -gt 1 ]; then
    default=$2
    read -p "$question [$default]? " answer
    if [ "$answer" == "" ]; then
        answer=$default
    fi
else
    read -p "$question? " answer
fi
echo $answer
}

select_file() {
# select from all or types of files in directory
# file names modes:
# pre (prefix)
# ext (extension)

local mydir
mode=$1
mydir=$2
file_type=$3

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
    file_list=$(ls ${file_type}*)
elif [ "$mode" == "-ext" ]; then
    file_list=$(ls *${file_type})
elif [ "$mode" == "-all" ]; then
    file_list=$(ls)
fi

select file in $file_list
do
    echo $file
    break
done
}

# ===== WWW related functions
wwwh() {
# check headers from WWW server
server=$1; port=${2:-80}
exec 5<> /dev/tcp/$server/$port
echo -e "HEAD / HTTP/1.0\nHost: ${server}\n\n" >&5
cat <5
exec 5<&-
}

parse_url() {
url=$1
pname="${url,,}"
# remove URL header
cname="${pname#http://}"
cname="${pname#https://}"
cname="${pname#ftp://}"
cname="${pname#scp://}"
cname="${pname#sftp://}"
# remove username and/or username:password part of hostname
cname="${pname#*:*@}"
cname="${pname#*@}"
# remove trailer /somedir/index.html*
cname=${pname%%/*}
cname=${pname%%:}
echo -e "$cname"
}

# network functions
mping() {
local t="$1"
local _ping="/bin/ping"
local c=$(parse_url "$t")
[ "$t" != "$c" ] && echo "Sending ICMP ECHO_REQUEST to \"$c\"..."
$_ping $c
}

my_host() {
local t="$1"
local _host="/usr/bin/host"
local c=$(parse_url "$t")
[ "$t" != "$c" ] && echo "Performing DNS lookups for \"$c\"..."
$_host $c
}

my_log() {
# ===== logging
log_mode=$1
log_file=$2
log_entry=$3
log_time=$(mytime -date_time)

if [ "$log_mode" == "-n" ]; then     # normal
    echo -e "$log_time $log_entry" >> $log_file
elif [ "$log_mode" == "-e" ]; then   # error
    echo -e "$log_time error: $log_entry" >> $log_file
elif [ "$log_mode" == "-r" ]; then   # rotate log file
    if [ -e $log_file ]; then
        mv $log_file ${log_file}_${log_time}
    else
        echo -e "$ERROR no such file $log_file"
    fi
fi
}

my_print() {
# ===== colorized print on screen
# incomplete
colors="red green blue yellow"
declare -a color_map
color_map['red']="\e[0;35m"
color_reset="\e[0m"
precolor=color_map[$1]

echo -e "${precolor}${myout}${postcolor}"
}

# ===== misc
# my_seq() {
# mode=$1
# seq_first=$2
# seq_incr=$3
# seq_last=$4
# string=$5
# task=$6
#
# if [ "$mode" == "echo" ]; then
#     for seq in $(seq $seq_first $seq_incr $seq_last)
#     do
#         echo "$seq"
#     done
# elif [ "$mode" == "printf" ]; then
#     for seq in $(seq $seq_first $seq_incr $seq_last)
#     do
#         printf "%d " $seq
#     done
# elif [ "$mode" == "_str" ]; then
#     for seq in $(seq $seq_first $seq_incr $seq_last)
#     do
#         printf "%s%d " $string $seq
#     done
# elif [ "$mode" == "str_" ]; then
#     for seq in $(seq $seq_first $seq_incr $seq_last)
#     do
#         printf "%d%s " $seq $string
#     done
# elif [ "$mode" == "-h" -o "$mode" == "" ]; then
#     echo -e "\nFunction use:\n    myseq <mode> <first> <increment> <last> <string>\n\tmode: echo, printf, [_str|str_]\n\n\tEx.: myseq str_ 11 2 22 my_string\n"
# fi
# }

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

tport() {
# check if port is open
server=$(usr_input server); port=$(usr_input port); proto=$(usr_input protocol tcp)
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
    grep $opt1 $myfile
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
seq_first=$2
seq_incr=$3
seq_last=$4
string=$5
task=$6

if [ "$mode" == "num" ]; then
    for seq in $(seq $seq_first $seq_incr $seq_last)
    do
        echo "$seq"
    done
elif [ "$mode" == "printf" ]; then
    for seq in $(seq $seq_first $seq_incr $seq_last)
    do
        printf "%d " $seq
    done
elif [ "$mode" == "_str" ]; then
    for seq in $(seq $seq_first $seq_incr $seq_last)
    do
        printf "%s%d " $string $seq
    done
elif [ "$mode" == "str_" ]; then
    for seq in $(seq $seq_first $seq_incr $seq_last)
    do
        printf "%d%s " $seq $string
    done
elif [ "$mode" == "-h" -o "$mode" == "" ]; then
    echo -e "\nFunction use:\n    myseq <mode> <first> <increment> <last> <string>\n\tmode: echo, pr
intf, [_str|str_]\n\tEx.: myseq str_ 11 2 22 my_string\nmodes: num printf _str str_\n"
fi
}

mkpack() {
# create a package for use elsewhere
# package will install files under $HOME/bin
# pack files list: full file path relative to $HOME directory; it may contain comments

USAGE="pack_utility -tar <pack files list (absolute path)> <pack name> <pack version> [dst_dir]"
pack_type=$1
pack_files_list=$2
pname=$3
pack_version=$4
dst_dir=${5:-${HOME}/tmp/$pname}
log_file=${dst_dir}/mkpack_${pname}.log

[ -e $log_file ] && rm $log_file

if [ $# -lt 4 ]; then
    echo -e "Usage:\n\t$USAGE"
fi

if [ ! -d ${dst_dir}/bin ]; then
    mkdir -p ${dst_dir}/bin
else
    rm -f ${dst_dir}/bin/*
fi

if [ "$pack_type" == "-tar" ]; then
#    cd
    pack_name="${dst_dir}/${pname}-${pack_version}.tar"
    [ -e $pack_name ] && rm $pack_name
    echo -e "\n----- creating installation pack:\n\t$pack_name"
    while read pack_file
    do
        [ -z "${pack_file%%#*}" ] && continue   # skip commented or empty lines
        echo -e "cp -p $pack_file ${dst_dir}/bin"  2>&1 >> $log_file
        cp -p $pack_file ${dst_dir}/bin
        if [ $? -ne 0 ]; then
            echo -e "$ERROR while copying $pack_file\n"
            return
        fi
    done < $pack_files_list
    cd $dst_dir
    tar cvf $pack_name bin 2>&1 >> $log_file
elif [ "$pack_type" == "-rpm" ]; then
    echo "under construction"
    return
    cd $dst_dir
    for mydir in "rpm/BUILD rpm/RPMS rpm/RPMS/i386 rpm/RPMS/i686 rpm/RPMS/noarch rpm/SOURCES rpm/SPECS rpm/SRPMS rpm/tmp"
    do
        [ ! -d $dir ] && mkdir $mydir
    done
    cat << EOM > ~/.rpmmacros
%_topdir               ${dst_dir}/rpm
%_tmppath              ${dst_dir}/rpm/tmp

EOM
    echo -e "----- building RPMs"
    cp ${YSI}.spec ${dst_dir}/rpm/SPECS/
    tar -zcvf ${dst_dir}/rpm/SOURCES/${pack_name}-$pack_version.tar.gz ${pack_name}-$pack_version
    rpmbuild -ba ${dst_dir}/rpm/SPECS/${YSI}.spec

    rpm --addsign ${pack_name}-$pack_version
else
    echo $usage
fi
echo -e "\n----- pack creation complete:\n$(ls -lh $pack_name)\n  LOG: $log_file\n"
}

make_line() {
size=$1
line_string="$2"
lstring=""

if [ "$size" -lt 1 ]; then
    echo -e "usage: make_line() $size $line_string"
    return
fi

for myseq in $(seq $size)
do
    if [ "$line_string" == "" ]; then
        lstring="${lstring} "
    else
        lstring="${lstring}${line_string}"
    fi
done
printf "%s" $lstring
}

application_lock(){
# lock application to prevent running two identical sessions at the same time, also unlock
# if locked, watch for number of seconds and return to caller

mode=$1
lock_file=$2

if [ $mode == "lock" ]; then
    echo "$$ $(date '+%F %T') $(whoami)" > $lock_file
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
    rm $lock_file
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

replace_var() {
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

list_servers() {
env=$1
myworkdir=$2

if [ "$env" == "" ]; then
    env=$(usr_input "environment " sqc)
fi
cd ${myworkdir}/${env}
server_type=$(usr_input "server type")
string=$(usr_input "string")
server_list=${myworkdir}/${env}/hosts.${env}.${server_type}

if [ "$string" != "" ]; then
    server.pl -q -env $env -ser $server_type -str $string -ac yes > $server_list
else
    server.pl -q -env $env -ser $server_type -ac yes > $server_list
fi
less $server_list
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

is_ip() {
# under construction
local myip=$1
local mystat=1
declare -a myipset
#IFS=. read -a myipset <<< "$myip"

if [[ $myip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    myip=($myip)
    IFS=$OIFS
    [[ ${myip[0]} -le 255 && ${myip[1]} -le 255 && ${myip[2]} -le 255 && ${myip[3]} -le 255 ]]
    stat=$?
fi
return $stat
}
