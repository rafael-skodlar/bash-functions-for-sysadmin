jupyter_dx() {
remoteAccount=$1
jsonFile=$2

echo -e "\n----- local:\njson file: $jsonFile"
echo -e "\n----- server side:\n%connect_info\n"

cat << EOM
ssh -N -f -L localhost:8888:localhost:8889 $remoteAccount

EOM
}

