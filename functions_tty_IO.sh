# 2012-10-17 Rafael Skodlar; TTY related functions

hl() {
# highlight
export R=$1
shift
egrep --color=always "|$R" $@
}

spinner() {
local text
text=$1

case $SPIN in
    "|")
            SPIN="/"
    ;;

    "/")
            SPIN="-"
    ;;

    "-")
            SPIN="\\"
    ;;

    "\\")
            SPIN="|"
    ;;

    *)
            SPIN="|"
    ;;
esac
printf "\r%5s %s" $text $SPIN
}

mycolors() {
GRAY="\[\033[1;30m\]"
LIGHT_GRAY="\[\033[0;37m\]"
CYAN="\[\033[0;36m\]"
LIGHT_CYAN="\[\033[1;36m\]"
NO_COLOUR="\[\033[0m\]"

case $TERM in
    xterm*|rxvt*)
        local TITLEBAR='\[\033]0;\u@\h:\w\007\]'
        ;;
    *)
        local TITLEBAR=""
        ;;
esac
}

