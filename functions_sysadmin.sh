# 2012-09-27 Rafael Skodlar; collected and created a number of reusable functions for use in scripts
# 2012-09-27 Rafael Skodlar; updated functions
# 2012-10-17 Rafael Skodlar; broke related functions into separate files

std_lables() {
# Standard lables used in scripts
# Note: parsing in some scripts using this file depends on LINE0*

LINE01="====="
LINE02="-----"
LINE03="....."
LINE04="+++++"
LINE05="_____"
LINE06="*****"
LINE07="|||||"
LINE08=">>>>>"
LINE09="<<<<<"
LINE10="^^^^^"

LINE20="======================================================================"
LINE21="===================="
LINE22="--------------------"
LINE23="...................."
LINE24="++++++++++++++++++++"
LINE25="____________________"

ABORT="_____ Aborting:"
NOTE="_____ Note:"
WARN="_____ Warning:"
MISSING="_____ Missing:"
ERROR="ERROR:"
}

ask_item() {
# return answer from user interaction
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
log_type=$1
log_file=$2
log_entry=$3
log_time=$(mytime -date_time)

if [ "$log_type" == "-n" ]; then     # normal
    echo -e "$log_time $log_entry" >> $log_file
elif [ "$log_type" == "-e" ]; then   # error
    echo -e "$log_time error: $log_entry" >> $log_file
fi
}

# ===== misc
myseq() {
mode=$1
seq_first=$2
seq_incr=$3
seq_last=$4
string=$5
task=$6

if [ "$mode" == "echo" ]; then
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
    echo -e "\nFunction use:\n    myseq <mode> <first> <increment> <last> <string>\n\tmode: echo, printf, [_str|str_]\n\tEx.: myseq str_ 11 2 22 my_string\n"
fi
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
echo -e "\n\t* available functions:\n"
awk -F\( '/\(\) {/{print $1}' ~/bin/functions_*.sh
}

tport() {
# check if port is open
server=$(usr_input server); port=$(usr_input port); proto=$(usr_input protocol tcp)
echo
exec 5<>/dev/${proto}/${server}/${port}
(( $? == 0 )) && exec 5<&-
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
log_type=$1
log_file=$2
log_entry=$3
log_time=$(mytime "-date_time0")

# write log file fomat at the beginning of file; future option

if [ "$log_type" == "-n" ]; then     # normal
    echo -e "$log_time $log_entry" >> $log_file
elif [ "$log_type" == "-e" ]; then   # error
    echo -e "$log_time error: $log_entry" >> $log_file
elif [ "$log_type" == "archive" ]; then   # archive log file
    [ -e $log_file ] && mv $log_file ${log_file}.$(mytime -date_time1)
fi
}

view_file() {
# view information file
mode=$1
myfile=$2
opt1=$3

if [ ! -e $myfile ]; then
    echo -e "$MISSING $myfile"
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
usage="Usage example:\npack_utility -tar pack_files_list pack_name pack_version dst_dir"
pack_type=$1
pack_files_list=$2
pname=$3
pack_version=$4
dst_dir=${5:-${HOME}/tmp}
log_file=${dst_dir}/mkpack_${pname}.log

[ -e $log_file ] && rm $log_file

if [ $# -lt 4 ]; then
    echo -e $usage
fi

[ ! -d $dst_dir ] && mkdir $dst_dir

if [ "$pack_type" == "-tar" ]; then
    #cd $HOME
    pack_name="${pname}-${pack_version}.tar"
    echo -e "\n$LINE02 creating installation pack:\n\t${dst_dir}/${pack_name}"
    [ -e ${dst_dir}/${pack_name} ] && cat /dev/null > ${dst_dir}/${pack_name}
    while read pack_file
    do
        tar rvf ${dst_dir}/${pack_name} $pack_file --exclude .svn 2>&1 >> $log_file
    done < $pack_files_list
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
    echo -e "$LINE02 building RPMs"
    cp ${YSI}.spec ${dst_dir}/rpm/SPECS/
    tar -zcvf ${dst_dir}/rpm/SOURCES/${pack_name}-$pack_version.tar.gz ${pack_name}-$pack_version
    rpmbuild -ba ${dst_dir}/rpm/SPECS/${YSI}.spec

    rpm --addsign ${pack_name}-$pack_version
else
    echo $usage
fi
echo -e "\n$LINE02 pack creation complete:\n$(ls -lh ${dst_dir}/${pack_name})\n  LOG: $log_file\n"
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

isdigit() {
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
