# functions under development
list_servers() {
env=$1
myworkdir=$2

if [ "$env" == "" ]; then
    env=$(usr_input -n "environment " sqc)
fi
cd ${myworkdir}/${env}
server_type=$(usr_input -n "server type")
string=$(usr_input -n "string")
server_list=${myworkdir}/${env}/hosts.${env}.${server_type}

if [ "$string" != "" ]; then
    server.pl -q -env $env -ser $server_type -str $string -ac yes > $server_list
else
    server.pl -q -env $env -ser $server_type -ac yes > $server_list
fi
less $server_list
}
