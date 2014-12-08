# Common Functions for use in numerous ysi* scripts;
# Make non-destructive changes only! Either add functions, or add to them,
# but they need to preserve previous names and functionality!
#
# 2013-03-29 Rafael Skodlar

std_lables() {
# Standard lables used in scripts
# Note: parsing in some scripts depends on core lines LINE0*; other are optional

LINE01="====="
LINE02="-----"
LINE03="....."
LINE04="+++++"
LINE05="_____"
LINE06="*****"
LINE07="|||||"
LINE08=">>>>>"
LINE09="^^^^^"

LINE20="======================================================================"
LINE21="===================="
LINE22="--------------------"
LINE23="____________________"

# deprecated LINE3*
#LINE30="_____ Note:"
#LINE31="_____ Warning:"
#LINE32="_____ Missing:"
#LINE33="_____ Error:"
#LINE34="verfy:"

# new vars
NOTE="_____ Note:"
WARN="_____ Warning:"
MISSING="_____ Missing:"
ERROR="_____ Error:"
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
local mydir
mydir=$1

if [ ! -d $mydir ]; then
    echo -e "no such directory: $mydir\n"
    return
fi

if [ $# -gt 1 ]; then
    file_type=$2
fi

cd $mydir

select file in $(ls *${file_type})
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
log_time=$(mytime "-log_time")

# write log file fomat at the beginning of file; future option

if [ "$log_type" == "-n" ]; then     # normal
    echo -e "$log_time $log_entry" >> $log_file
elif [ "$log_type" == "-e" ]; then   # error
    echo -e "$log_time error: $log_entry" >> $log_file
elif [ "$log_type" == "archive" ]; then   # archive log file
    mv $log_file ${log_file}.$(mytime -datetime)
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
    echo -e "\nFunction use:\n    myseq <mode> <first> <increment> <last> <string>\n\tmode: echo, pr
intf, [_str|str_]\n\tEx.: myseq str_ 11 2 22 my_string\n"
fi
}

pack_utility() {
# create a package for use elsewhere
pack_type=$1
pack_name=$2
pack_version=$3
src_dir=$4
pack_files=$5
dst_dir=${6:-/tmp}

if [ "$pack_type" == "-tar" ]; then
    cd $src_dir
    echo -e "\n$LINE20\n  Creating installation pack: ${pack_name}-$pack_version\n\ttop directory: $src_dir\n\tdst directory: $dst_dir"

    for myfile in "$pack_files"
    do
        echo -e "$LINE03 adding file: $myfile"
        tar rf ${pack_name}-$pack_version $myfile
    done
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
fi
echo -e "\n$LINE02 pack creation complete: ${pack_name}-$pack_version"
ls -l ${pack_name}-$pack_version
}

hip_chat() {
# FORMAT: room_id, from, message

URL="https://api.hipchat.com/v1/rooms/message"
chitchat_room=44180         # chitchat default room ODP
chitchat_from=ODP
auth_token=167f439e172fd13130fe9d9d61c8a6

if [ "$1" == "ODP" ]; then
    room_id=44180
else
    room_id=${1:-$chitchat_room}
fi

myfrom=$2
chat_message=$3

if [ "$message" != "" ]; then
    curl -k -sS -d "auth_token=${auth_token}&room_id=${room_id}&from=$myfrom Bot&notify=1&message=$chat_message" $URL
else
    echo -e "$LINE32 message"
fi
}

