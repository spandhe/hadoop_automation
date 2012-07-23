#!/bin/bash

numOfSlaves=0
while read line
do numOfSlaves=$(($numOfSlaves+1));
done < $1

echo "Retrieving IP Addresses of wmx0 of all the nodes"
filecontent=( `cat "$1" `)
rm IPAddresses

for t in "${filecontent[@]}"
do
ip_addr=$t
echo $ip_addr
echo $(ssh ${ip_addr} "bash -s" < getIP.sh) >> IPAddresses
done


echo "Modifying /etc/hosts of all the nodes"
ip=( `cat "IPAddresses" `)
for t in "${filecontent[@]}"
do
for ((i=0;i<numOfSlaves;i++))
do
ssh ${t} "bash -s" < ModifyHost.sh "${ip[$i]}" "${filecontent[$i]}"
echo "${ip[$i]}" "${filecontent[$i]}"
done
#i=$(($i+1));
done


echo "copying ssh-id to all the slaves"
for t in "${filecontent[@]}"
do
./sshCopyId.sh $t
done

echo "Starting WIMAX modules on all the nodes"
for t in "${filecontent[@]}"
do
ip_addr=$t
echo $(ssh ${ip_addr} "bash -s" < startWimax.sh)
done

echo "Schecudling periodic WIMAX link status check"

./checkWimaxStatus.sh &

echo "Copying $1 to /usr/local/hadoop/conf/slaves"
cp $1 /usr/local/hadoop/conf/slaves

echo "logging in as hduser"
cp $1 /home/hduser/.
su - hduser