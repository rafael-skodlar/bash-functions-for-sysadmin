# 2012-10-17 Rafael Skodlar; update to colors config
#

# colors
NOBOLD="\033[0m"
RED="\033[31m"
BLUE="\033[34m"
CYAN="\033[36m"
WHITE="\033[37m"

test_colors() {
cat << ECOLORS
${CYAN}cyan${RED}red${NOBOLD}
${BLUE}blue${WHITE}white${NOBOLD}"
ECOLORS
}
