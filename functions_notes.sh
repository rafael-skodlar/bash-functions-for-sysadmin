# notes functions

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
    note=$(select_file -all $dir)
    vi $note
elif [ "$opt" == "-s" ]; then
    read -p "$LINE3 search string (single word only) " string
    printf "string: '%s'" $string
    grep $string *
elif [ "$opt" == "-v" ]; then
    note=$(select_file -pre $dir notes)
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

