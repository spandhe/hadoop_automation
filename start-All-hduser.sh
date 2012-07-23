echo "ssh into all the hosts to add slave's fingerprint to master's known_hosts"
./sshAndExit.sh

numOfSlaves=0
while read line
do numOfSlaves=$(($numOfSlaves+1));
done < ListOfSlaves

filecontent=( `cat "ListOfSlaves" `)
for t in "${filecontent[@]}"
do
ip_addr=$t
scp /usr/local/hadoop/*site.xml hduser@$ip_addr:/usr/local/hadoop/conf/
done

echo "Starting DFS on all nodes"
/usr/local/hadoop/bin/start-dfs.sh

echo "checking status on all nodes"
rm StatusJps
for t in "${filecontent[@]}"
do
ip_addr=$t
echo $(ssh ${ip_addr} "bash -s" < JPS.sh) >> StatusJps
done

NumOfDataNodes=$(cat StatusJps | grep Datanode | wc -l)

if[$NumOfDataNodes != $numOfSlaves]
then
        echo "Error: Datanodes not started on all the slaves"
        /usr/local/hadoop/bin/stop-dfs.sh
        for t in "${filecontent[@]}"
        do
        ip_addr=$t
        ssh ${ip_addr} rm -rf /app/hadoop/tmp/dfs/data/
        done
        echo "Issue resolved. Starting datanodes again"
        /usr/local/hadoop/bin/start-dfs.sh
else
        echo "Success: Datanodes started successfully"
fi

echo "Starting MAPRED on all nodes"
/usr/local/hadoop/bin/start-mapred.sh

echo "checking status on all nodes"
rm StatusJps
for t in "${filecontent[@]}"
do
ip_addr=$t
echo $(ssh ${ip_addr} "bash -s" < JPS.sh) >> StatusJps
done

NumOfMapredNodes=$(cat StatusJps | grep Tasktracker | wc -l)

if[$NumOfMapredNodes != $numOfSlaves]
then
echo "Error: Tasktrackers not started on all the slaves"
else
echo "Success: Tasktrackers started successfully"
fi