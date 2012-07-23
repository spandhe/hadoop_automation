#!/bin/bash
/usr/bin/expect <<EOD

spawn ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@$1
expect "hduser@$1's password:"
send "abcd\r\n"
interact
EOD
 
automatic ssh and exit
>>  cat sshAndExit.sh
#!/bin/bash
filecontent=( `cat "ListOfSlaves" `)
for t in "${filecontent[@]}"
do
ip_addr=$t
#echo $ip_addr
/usr/bin/expect <<EOD
spawn ssh -o "StrictHostKeyChecking no" $ip_addr
expect "hduser@$ip_addr"
send "exit"
interact
EOD
done