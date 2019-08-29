# ===== WWW related functions
# 2016-07-03 Rafael Skodlar

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
myURL="${url,,}"
# remove URL header
urlPart="${myURL#http://}"
urlPart="${myURL#https://}"
urlPart="${myURL#ftp://}"
urlPart="${myURL#scp://}"
urlPart="${myURL#sftp://}"
# remove username and/or username:password part of hostname
urlPart="${myURL#*:*@}"
urlPart="${myURL#*@}"
# remove trailer /somedir/index.html*
urlPart=${myURL%%/*}
urlPart=${myURL%%:}
echo -e "$urlPart"
}

