#!/bin/bash

arch=$(uname -a)

#print the cpu info , grep the cpu socket line, but then delete any letter and show only the number
PhyC=$(lscpu | grep "Socket(s)" | tr -cd "0-9" && printf '\n')

#print the CPUs available which are vCPUs then delete , using tr anything other than numbers
VirC=$(lscpu | grep "^CPU(s)" | tr -cd "0-9" && printf '\n')

#print what the free command gives(info about the system memory and SWAP) grep the swap 
#tr -s , to supress all spaces to one
#then cut -d " " specify the delimiter by which to look for the second column
Ram=$(free -m | grep "Mem" | tr -s " " | cut -d " " -f 2 )

#same thing as the one before, only with the third field
Used=$(free -m | grep "Mem" | tr -s " " | cut -d " " -f 3 )

#if the first field is Mem: , print with two numbers after the float num, the percentage calculated
#by dividing the total by used and multiply by 100 according to the percentage formula
Per=$(free | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# print the column of the total of the disk partitions where the first column is total, and subtract from what you'll print G, for the Gb in the command output , in the end, print
Tdis=$(df -h --total | awk '$1 == "total" {sub("G", "", $2)}; END {print $2}')

# print the column of the used where the first column is total
Udis=$(df -m --total | awk '$1 == "total" {print $3}')

# print the column of the percentage where first column is total
Dus=$(df -h --total | awk '$1 == "total" {print $5}')

#mpstat shows the stat of CPUS , -P ALL to show the stats of all CPUS at once, awk to match where
#the third field is all , calculate the load by subtracting the idle percentage from 100.
CpuL=$(mpstat -P ALL | awk '$3 == "all" {print 100 - $NF"%"}')

#the who command shows you the users who are logged in, tr command to remove all letters, only letting the first field of the exact date, and the second field for the exact hour and minute
Lrebo=$(who -b | tr -d "a-zA-Z" | awk '{print $1" "$2}')

# a function where it gets the output of lsblk with only the type and name of partiotions and looks for lvm there, -q in grep returns 1 or 0 in case of failure of finding what it was looking :
#then the function runs whenever it is called inside the variable where itself is run whenever its value is printed by wall (broadcast to all users)
function Lvmu {
	if lsblk -o NAME,TYPE | grep -q 'lvm'; then
		echo "yes"
	else
    		echo "no"
fi
}
lvmUse=$(Lvmu)

# cleanly output the ESTABLISHED connections by outputting the number of every line with ESTABLISHED on it
tcp=$(netstat -nat | grep ESTABLISHED | wc -l)

#print how many lines of users connected to the server
Ulog=$(who | wc -l)

#displays the ip address assosiated with the Hostname (used to connect with ssh to)
IP=$(hostname -I)

#printn the Mac adress cleanly.
MAC=$(ip link show | grep ether | awk '{print $2}')

#get from the journalctl the lines with COMMAND on them , then convert them to a number
Su=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
wall "
	#Architecture: $arch
	#CPU Physical : $PhyC
	#vCPU : $VirC
	#Memory Usage: $Used/$Ram"Mb" ($Per%)
	#Disk Usage: $Udis/$Tdis"Gb" ($Dus) 
	#CPU load: $CpuL
	#Last boot: $Lrebo
	#LVM use : $lvmUse
	#Connections TCP : $tcp ESTABLISHED
	#User log: $Ulog
	#Network: IP $IP ($MAC)
	#Sudo : $Su cmd"
