# system functions
# 2014-12-13 Rafael Skodlar; operating system related functions

sys_memory() {
if [ "$1" == "total" ]; then
    memoryx=$(free | grep Mem | awk '{print $2}')
elif [ "$1" == "used" ]; then
    memoryx=$(free | grep Mem | awk '{print $3}')
elif [ "$1" == "free" ]; then
    memoryx=$(free | grep Mem | awk '{print $4}')
else
    memoryx="unknown option"
fi
echo $memoryx
}

sys_swap() {
if [ "$1" == "total" ]; then
    swapx=$(free | grep Swap | awk '{print $2}')
elif [ "$1" == "used" ]; then
    swapx=$(free | grep Swap | awk '{print $3}')
elif [ "$1" == "free" ]; then
    swapx=$(free | grep Swap | awk '{print $4}')
else
    swapx="unknown option"
fi
echo $swapx
}
