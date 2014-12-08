# debugg functions for bash scripts
# 2012-02-15 Rafael Skodlar

debug_file_view() {
# parameter: file name, "all", and file type
info_file=$1

if [ "$info_file" == "all" ]; then
    myfiles=$(ls)
elif [ "$info_file" == "log" ]; then
    myfiles=$(ls *log)
elif [ "$info_file" == "hosts" ]; then
    myfiles=$(ls *hosts)
elif [ "$info_file" == "processes" ]; then
    myfiles=$(ls *processes)
elif [ "$info_file" == "select" ]; then
    MENU="RETURN $(ls)"
    select menu_item in $MENU
    do
        if [ "$menu_item" == "RETURN" ]; then
            echo -e "\n\t\t--- press Enter for menu ---"
            break
        else
            less $menu_item
        fi
        break
        #echo -e "\n\t\t--- press Enter for menu ---"
    done
else
    echo -e "view file:$info_file\n"
    less $info_file
    return
fi

}

debug() {
# for debugging purposes.
# file:<filename> allows for examining the <filename>
# usage: debug file:some.hosts
LINE=">>>>>"
arg1=$1

echo -e "\n$LINE DEBUG start\narg1=$arg1"
if [ "${arg1#file:}" -a -e ${arg1#file:} ]; then
    debug_file_view ${arg1#file:}
elif [ ${arg1#mesg:} ]; then
    echo -e "message: ${arg1#mesg:}"
else
    echo -e "ARG1:$arg1"
fi
echo -e "\n$LINE DEBUG end\n"
}
