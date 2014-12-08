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
LINE09="^^^^^"

LINE20="======================================================================"
LINE21="===================="
LINE22="--------------------"

LINE30="_____ Note:"
LINE31="_____ Warning:"
LINE32="_____ Missing:"
LINE33="_____ Error:"
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

make_note() {
notetype=$1
note=$2

if [ "$notetype" == "-n" ]; then
    echo -e "\n$LINE21 NOTE $LINE21"
    echo -e "\n$note"
    echo -e "\n$LINE21 NOTE $LINE21\n"
elif [ "$notetype" == "-e" ]; then
    echo -e "\n$LINE20 Error! $LINE20"
    echo -e "\n$note"
    echo -e "\n$LINE20 Error! $LINE20\n"
elif [ "$notetype" == "-w" ]; then
    echo -e "\n$LINE20 Warning! $LINE20"
    echo -e "\n$note"
    echo -e "\n$LINE20 Warning! $LINE20\n"
fi
}

notes() {
local opt dir
opt=$1
dir="${HOME}/info/notes"
olddir=$(pwd)
std_lables

if [ "$opt" == "" ]; then
    cat << EOM

${LINE0}${LINE0}
	-c    (clean - remove backup files)
	-e    (edit)
	-l    (list)
	-ll   (long list)
	-t    (tar all files)
	-v    (view)
	-s    (search; prompts for word)
${LINE0}${LINE0}

EOM
fi

cd ${HOME}/info/notes
echo -e "$LINE0\n"

if [ "$opt" == "-l" ]; then
    ls
elif [ "$opt" == "-ll" ]; then
    ls -l | less
elif [ "$opt" == "-e" ]; then
    note=$(select_file $dir)
    vi $note
elif [ "$opt" == "-s" ]; then
    read -p "$LINE3 search string (single word only) " string
    printf "string: '%s'" $string
    grep $string *
elif [ "$opt" == "-v" ]; then
    note=$(select_file $dir)
    less $note
elif [ "$opt" == "-t" ]; then
    cd ${HOME}/info
    tar cvfp ${HOME}/tmp/notes.tar notes
    ls -l ${HOME}/tmp/notes.tar
elif [ "$opt" == "-c" ]; then
    cd $dir
    rmnotes=$(ls *~)
    echo -e "----> about to remove $rmnotes\n"
    for file in $(echo $rmnotes)
    do
        read -p "..... remove $file [y/Y]? " answer
    if [ -z "$answer" -o "$answer" == "y" -o "$answer" == "Y" ]; then
            rm $file
            echo -e "\nremoved: $file"
        fi
    done
fi
cd $olddir
echo -e "\n${LINE2}${LINE2}\n"
}

select_file() {
local mydir
mydir=$1

if [ ! -d $mydir ]; then
    echo -e "no such directory: $mydir\n"
    return
fi
cd $mydir
select file in $(ls)
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
server=$(ask_item server); port=$(ask_item port); proto=$(ask_item protocol tcp)
echo
exec 5<>/dev/${proto}/${server}/${port}
(( $? == 0 )) && exec 5<&-
}

host() {
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

ret_status() {
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
awk -F\( '/\(\) {/{print $1}' bin/functions_*.sh
}

pack_utility() {
# create a tar package for a utility for use elswhere
top_dir=$1

cd $top_dir
echo -e "\n$LINE20\nCreating installation pack for utility: $0\n\ttop directory: $top_dir"

for util_file in "$PACK_FILES"
# pack all utility related files for installation elsewhere
do
    echo -e "$LINE03 files: $util_file"
    tar rf $PACK_TAR $util_file
done
echo -e "\n$LINE02 pack complete: $PACK_TAR"
ls -l $PACK_TAR
echo -e "\nscp $PACK_TAR \n"
}

