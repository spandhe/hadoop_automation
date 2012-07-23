rm /tmp/WimaxStatus
filecontent=( `cat "ListOfSlaves" `)
while true
do
for t in "${filecontent[@]}"
do
ip_addr=$t
echo $ip_addr
echo $(ssh ${ip_addr} "bash -s" < checkStatus.sh) >> /tmp/WimaxStatus
done
sleep 600
done