#!/bin/sh
clear
export LANG=C
LOGPATH="/data/g1/inspect/logs"
HOST=`/bin/hostname`
TODAY=`/bin/date +%Y%m%d`
DAY=`/bin/date +%d`

basicsinfo()
{
  echo -e "\n"
  echo "### 1. Basic Info ### "
  echo "--------------------------------------------------------------------"
  echo "Host Name : `hostname`"
  echo "OS Version : `uname -r`(`uname -v`)"
  echo "--------------------------------------------------------------------"
  echo "Kubectl Version (Client) :  "
  echo " - Major: "`kubectl version | head -1 | cut -d "\"" -f2`
  echo " - Minor: "`kubectl version | head -1 | cut -d "\"" -f4`
  echo " - GitVersion: "`kubectl version | head -1 | cut -d "\"" -f6`
  echo " - GitCommit: "`kubectl version | head -1 | cut -d "\"" -f8`
  echo " - BuildDate: "`kubectl version | head -1 | cut -d "\"" -f12`
  echo " - GoVersion: "`kubectl version | head -1 | cut -d "\"" -f14`
  echo " - Platform: "`kubectl version | head -1 | cut -d "\"" -f18`
  echo " --------------- "
  echo "Kubectl Version (Server) :  "
  echo " - Major : "`kubectl version | tail -1 | cut -d "\"" -f2`
  echo " - Minor : "`kubectl version | tail -1 | cut -d "\"" -f4`
  echo " - GitVersion : "`kubectl version | tail -1 | cut -d "\"" -f6`
  echo " - GitCommit: "`kubectl version | tail -1 | cut -d "\"" -f8`
  echo " - BuildDate: "`kubectl version | tail -1 | cut -d "\"" -f12`
  echo " - GoVersion: "`kubectl version | tail -1 | cut -d "\"" -f14`
  echo " - Platform: "`kubectl version | tail -1 | cut -d "\"" -f18`
  echo "--------------------------------------------------------------------"
  echo "HyperData Image : " `kubectl describe po -n hyperdata $(kubectl get po -n hyperdata | grep hyperdata-hd | awk '{print $1}') | grep Image | head -1 | cut -d "/" -f2`
  echo ""
  echo "--------------------------------------------------------------------"
  echo "# 1-1. System Memory Info                                           "
  echo "       (except if 0kb)                                              "
  echo "--------------------------------------------------------------------"
  cat /proc/meminfo | awk '{if($2!=0) print $0}'
  echo ""
  memusage=`top -n 1 -b | grep "Mem"`
  MAXMEM=`echo $memusage | cut -d " " -f4 | awk '{print substr($0,1,length($0)-2)}'`
  USEDMEM=`echo $memusage | cut -d" " -f8 | awk '{print substr($0,1,length($0)-2)}'`
  USEDMEM1=`expr $USEDMEM \* 100`
  PERCENTAGE=`expr $USEDMEM1 / $MAXMEM`%
  echo "=> Total Memory: $MAXMEM MiB, Used Memory: $USEDMEM MiB, Used Memory Percentage: $PERCENTAGE"
  echo "--------------------------------------------------------------------"
  echo ""
  echo "--------------------------------------------------------------------"
  echo "# 1-2. CPU Model              "                                   
  echo "--------------------------------------------------------------------" 
  cat /proc/cpuinfo | grep -P "processor|cpu|name" | grep -Ev "cpuid_ |cpuid aperfmperf|cpu_" >> cpuinfo.txt
  sed -i'' -r -e "/cpuid level/a\---" cpuinfo.txt
  sed '$ d' cpuinfo.txt -i
  cat cpuinfo.txt
  rm cpuinfo.txt -f
  echo "--------------------------------------------------------------------" 
  echo ""
  echo "--------------------------------------------------------------------"
  echo "# 1-3. Top Summary               "                                   
  echo "--------------------------------------------------------------------"
  top -b -n 1 | head
  echo ""
  echo "=> Percentage of CPU in use :" `top -b -n1 -p 1 | fgrep "Cpu(s)" | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.f%", prefix, 100 -v }'`
  echo "--------------------------------------------------------------------" 

return 0
exit 0
}

basicinfo()
{

  echo -e "\n"
        echo -e "\033[1;4;5mprocessing\033[1;4;0m"
        echo -e "\n"
        echo " checked basic info OK "
        echo -ne " choice reporting method .. [\033[1;4;31mS\033[1;4;0mcreen/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                S|s )
                        echo -e "\n\n"
                        echo -e "\033[1;4;5mprocessing\033[1;4;0m"
                        sleep 1
                        basicsinfo ;;

                F|f )
                        echo -e "\n"
                        tmp_file=$LOGPATH/$TODAY.basic.info.log
                        echo " write .. $tmp_file " 
                        echo -n > $tmp_file
                        basicsinfo  >> $tmp_file ;;


                Q|q )
                        exit 0 ;;
        esac

        echo -e "\n"
        echo " End Report."
        echo -e "\n"
        echo -ne " return main menu ? [\033[1;4;31mR\033[1;4;0meturn/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                Q|q )
                        exit 0 ;;
                F|f )
                        echo -e "\n"
                        tmp_file=$LOGPATH/$TODAY.basic.info.log
                        echo " write .. $tmp_file " 
                        echo -n > $tmp_file
                        basicsinfo >> $tmp_file ;;
                R|r )
                        clear
                        return 0 ;;
        esac

}


diskscheck()
{
	echo "--------------------------------------------------------------------" 
    echo "# 2. Disk Check and Mount info                                    "
    echo "--------------------------------------------------------------------"
    /sbin/fdisk -l 
    echo "------------------------------------------------------------------"
    echo "# 2-1. Partitions Details                                    " 
    echo "------------------------------------------------------------------" 
    /bin/cat /proc/partitions 
    echo "------------------------------------------------------------------"
    echo "# 2-2. Disk free Details                                    " 
    echo "------------------------------------------------------------------" 
    /bin/df -h | head
    echo "-----------------------------------------------------------------" 
    /bin/df -i | head
    echo "------------------------------------------------------------------"
    echo "# 2-3. Mount Details                                    " 
    echo "-----------------------------------------------------------------"
    /bin/mount | head
    echo "--------------------------------------------------------------------"


return 0

}

diskcheck()
{
	echo -e "\n"
        echo -e "\033[1;4;5mprocessing\033[1;4;0m"
        sleep 1

        echo -e "\n"
        echo " checked disk OK "
        echo -ne " choice reporting method .. [\033[1;4;31mS\033[1;4;0mcreen/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                S|s )
                        echo -e "\n\n"
                        diskscheck ;;
                F|f )
                        echo -e "\n"
			tmp_file=$LOGPATH/$TODAY.disk.system.log
                        echo " write .. $tmp_file " 
			# clear file
			echo -n > $tmp_file
			diskscheck >> $tmp_file ;;
                Q|q )
                        exit 0 ;;
        esac

        echo -e "\n"
        echo " End Report."
        echo -e "\n"
        echo -ne " return main menu ? [\033[1;4;31mR\033[1;4;0meturn/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                R|r )
                        clear
                        return 0 ;;

                F|f )
                        echo -e "\n"
			tmp_file=$LOGPATH/$TODAY.disk.system.log
                        echo " write .. $tmp_file " 
			# clear file
			echo -n > $tmp_file
			diskscheck >> $tmp_file ;;
                Q|q )
                        exit 0 ;;

        esac

}

networkscheck() 
{

	echo "--------------------------------------------------------------------"
	echo "# 3. Network Check & Status                                         "
	echo "--------------------------------------------------------------------"
    echo "# 3-1. IP Address List                                           "
	echo "--------------------------------------------------------------------" 
	/sbin/ip addr list        
    echo "--------------------------------------------------------------------"
    echo "# 3-2. IFCONFIG Details                                         "
	echo "--------------------------------------------------------------------"
	/sbin/ifconfig -a 
	echo "--------------------------------------------------------------------" 
	/bin/cat /etc/sysconfig/network-scripts/ifcfg-*
	echo "------------------------------------------------------------" 
	echo " # 3-3 .Network connectaion status" 
	echo "------------------------------------------------------------" 
    echo "Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      PID/Program name"
        for i in $(netstat -natpeu | grep ESTABLISHED  | cut -d "/" -f2 | sort | uniq)
        do
                echo "`netstat -natpeu | grep ESTABLISHED | grep $i | head -1` x `netstat -natpeu | grep ESTABLISHED  | cut -d "/" -f2 | sort | uniq -c | grep $i |awk '{print$1'}`"
        done
	echo "---------------" 
    echo "Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      PID/Program name"
        for j in $(netstat -natpeu | grep LISTEN | awk '{print$9}' | cut -d "/" -f2  | sort | uniq)
        do
                echo "`netstat -natpeu | grep LISTEN | grep $j | head -1` x `netstat -natpeu | grep LISTEN | cut -d "/" -f2 | sort | uniq -c | grep $j |awk '{print$1}'`"
        done
	echo "------------------------------------------------------------" 
}

networkcheck()
{
        echo -e "\n"
        echo -e "\033[1;4;5mprocessing\033[1;4;0m"
        sleep 3

        echo -e "\n"
        echo " checked network info OK "
        echo -ne " choice reporting method .. [\033[1;4;31mS\033[1;4;0mcreen/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in 

                S|s ) 
                        echo -e "\n\n"
                        networkscheck ;;

                F|f ) 
			tmp_file=$LOGPATH/$TODAY.network.system.log
                        echo -e "\n"
                        echo " write .. $tmp_file " 
			echo -n > $tmp_file
			networkscheck >> $tmp_file ;;

                Q|q ) 
                        exit 0 ;;
        esac

        echo -e "\n"
        echo " End Report."
        echo -e "\n"
        echo -ne " return main menu ? [\033[1;4;31mR\033[1;4;0meturn/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                Q|q )
                        exit 0 ;;
                F|f ) 
			tmp_file=$LOGPATH/$TODAY.network.system.log
                        echo -e "\n"
                        echo " write .. $tmp_file " 
			echo -n > $tmp_file
			networkscheck >> $tmp_file ;;
                R|r )
                        clear
                        return 0 ;;
        esac
}

kubescheck()
{
        echo "--------------------------------------------------------------------"
        echo "# 5. Kubectl -n hyperdata Check"
        echo "--------------------------------------------------------------------"
        systemctl status kubelet >> ./tmp.txt
        head ./tmp.txt
        rm ./tmp.txt -f
        echo "-----------------------------------------------------------------"
        kubectl get po -n hyperdata -o wide
        echo "-----------------------------------------------------------------"
        kubectl exec -n hyperdata $(kubectl get po -n hyperdata | grep hyperdata-hd | awk '{print $1}')  -it -- /bin/bash -c "source ~/.bashrc && jps "
        echo "-----------------------------------------------------------------"
        kubectl exec -ti -n hyperdata $(kubectl get po -n hyperdata | grep hyperdata-hd | awk '{print$1}') -- tail /home/hyperdata/hyperdata20/proobject7/logs/ProObject.log
        echo "-----------------------------------------------------------------"

return 0 

}


kubecheck()
{
        echo -e "\n"
        echo -e "\033[1;4;5mprocessing\033[1;4;0m"
        sleep 1
        echo -e "\n"
        echo " checked kube OK "
        echo -ne " choice reporting method .. [\033[1;4;31mS\033[1;4;0mcreen/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                S|s )
                        echo -e "\n\n"
                        kubescheck ;;

                F|f )
                        echo -e "\n"
			tmp_file=$LOGPATH/$TODAY.kube.hyperdata.log
                        echo " write .. $tmp_file " 
			echo -n > $tmp_file
			kubescheck >> $tmp_file ;; 
               Q|q) 
			exit 0 ;;
	 	esac
			 echo -e "\n"
			 echo " End Report."
			 echo -e "\n"
			 echo -ne " return main menu ? [\033[1;4;31mR\033[1;4;0meturn/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
		        read choice
			case $choice in

				Q|q )
					exit 0 ;;
                                F|f )
                                        echo -e "\n"
                                        tmp_file=$LOGPATH/$TODAY.kube.hyperdata.log
                                        echo " write .. $tmp_file " 
                                        echo -n > $tmp_file
                                        kubescheck >> $tmp_file ;; 
				R|r )
					clear
					return 0 ;;
		esac	
}


systemfullog() {

# clear file
tmp_file=$LOGPATH/$TODAY.$HOST.system_full.log
echo "--------------------------------------------------------------------" >> $tmp_file
echo "# 1. Basic Info                                                     " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "# 1-1. System Memory-Info                                            " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
/bin/cat /proc/meminfo  >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
memusage=`top -n 1 -b | grep "Mem"`
MAXMEM=`echo $memusage | cut -d " " -f4 | awk '{print substr($0,1,length($0)-2)}'`
USEDMEM=`echo $memusage | cut -d" " -f8 | awk '{print substr($0,1,length($0)-2)}'`
USEDMEM1=`expr $USEDMEM \* 100`
PERCENTAGE=`expr $USEDMEM1 / $MAXMEM`%
echo "Total Memory: $MAXMEM MiB, Used Memory: $USEDMEM MiB, Used Memory Percentage: $PERCENTAGE"  >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "# 1-2. CPU Model              "                                   >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
cat /proc/cpuinfo | grep -P "processor|cpu|name" | grep -Ev "cpuid_ |cpuid aperfmperf|cpu_" >> cpuinfo.txt
sed -i'' -r -e "/cpuid level/a\------------" cpuinfo.txt
cat cpuinfo.txt >> $tmp_file
rm cpuinfo.txt -f
echo "--------------------------------------------------------------------" >> $tmp_file
echo "Percentage of CPU in use : `top -b -n1 -p 1 | fgrep "Cpu(s)" | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.f%n", prefix, 100 -v }'` %" >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "									  " >> $tmp_file
echo "									  " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "# 2. Disk Check and Mount info                                    " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
/sbin/fdisk -l >> $tmp_file
echo "------------------------------------------------------------------" >> $tmp_file
/bin/cat /proc/partitions >> $tmp_file
echo "------------------------------------------------------------------" >> $tmp_file
/bin/df -h      >> $tmp_file
echo "-----------------------------------------------------------------" >> $tmp_file
/bin/df -i      >> $tmp_file
echo "-----------------------------------------------------------------" >> $tmp_file
/bin/mount      >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "									  " >> $tmp_file
echo "									  " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "# 3. Network Check & Status                                         " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
/sbin/ifconfig -a >> $tmp_file
echo echo "--------------------------------------------------------------------" >> $tmp_file
/sbin/ip addr list  >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
/bin/cat /etc/sysconfig/network-scripts/ifcfg-* >> $tmp_file
echo "------------------------------------------------------------" >> $tmp_file
echo " Network connectaion status" >>$tmp_file
echo "------------------------------------------------------------" >> $tmp_file
/bin/netstat -natpeu | grep ESTABLISHED >> $tmp_file
echo "------------------------------------------------------------" >> $tmp_file
/bin/netstat -natpeu | grep LISTEN      >> $tmp_file
echo "------------------------------------------------------------" >> $tmp_file
echo "									  " >> $tmp_file
echo "									  " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "# 4. Kube & HyperData Status              "                                   >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "#Kube Status" >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
systemctl status kubelet >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
kubectl get po -n hyperdata -o wide >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "#HyperData " >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
kubectl exec -n hyperdata $(kubectl get po -n hyperdata | grep hyperdata-hd | awk '{print $1}')  -it -- /bin/bash -c "source ~/.bashrc && jps "
echo "--------------------------------------------------------------------" >> $tmp_file
kubectl exec -ti -n hyperdata $(kubectl get po -n hyperdata | grep hyperdata-hd | awk '{print$1}') -- tail /home/hyperdata/hyperdata20/proobject7/logs/ProObject.log
 >> $tmp_file
echo "--------------------------------------------------------------------" >> $tmp_file
echo "									  " >> $tmp_file
echo "									  " >> $tmp_file

return 0 

}

tiberocheck()
{
  echo -e "\n"
        echo -e "\033[1;4;5mprocessing\033[1;4;0m"

        sleep 2
        echo -e "\n"
        kubectl cp -n hyperdata ./tb_check_sql.sh $(kubectl get po -n hyperdata | grep tibero-pod | awk '{print $1}'):/db/tibero6/tb_check_sql.sh
        PS_CHECK=$(kubectl exec -n hyperdata $(kubectl get po -n hyperdata | grep tibero-pod | awk '{print $1}') -it -- ps -ef |grep tbsvr |grep -v grep)
        SQL_CHECK=$(kubectl exec -n hyperdata $(kubectl get po -n hyperdata | grep tibero-pod | awk '{print $1}') -it -- /db/tibero6/tb_check_sql.sh )
        SYSLOG_CHECK=$(kubectl exec -n hyperdata $(kubectl get po -n hyperdata | grep tibero-pod | awk '{print $1}') -it --  cat /db/tibero6/instance/tibero/log/slog/sys.log | grep -e "ec =" -e "ec=" |tail -n20)

        echo "--------------------------------------------------------------------"
        echo "# 5. Tibero Check"
        echo "--------------------------------------------------------------------"
        echo "## 5-1. TB Process Cehck"
        echo ""
        echo "UID          PID    PPID  C STIME TTY          TIME CMD"
        echo "${PS_CHECK} "
        echo "--------------------------------------------------------------------"
        echo "${SQL_CHECK} "
        echo "--------------------------------------------------------------------"
        echo "## 5-6. TB syslog Error Check "
        echo ""
        echo "${SYSLOG_CHECK} "
        echo "--------------------------------------------------------------------"
        echo " End Report."

        echo " checked Tibero Staus OK "
        echo -ne " choice reporting method .. [\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in
                F|f )
                        echo -e "\n"
                        tmp_file=$LOGPATH/$TODAY.tibero.check.log
                        echo " write .. $tmp_file " 
                        echo "--------------------------------------------------------------------" > $tmp_file
                        echo "# 5. Tibero Check                                                   " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file
                        echo "## 5-1. TB Process Cehck                                            " >> $tmp_file
                        echo "" >> $tmp_file
                        echo "${PS_CHECK} " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file
                        echo "${SQL_CHECK} " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file
                        echo "## 5-6. TB syslog Error Check                                       " >> $tmp_file
                        echo "" >> $tmp_file
                        echo "${SYSLOG_CHECK} " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file ;;

                Q|q )
                        exit 0 ;;
        esac

        echo -e "\n"
        echo " End Report."
        echo -e "\n"
        echo -ne " return main menu ? [\033[1;4;31mR\033[1;4;0meturn/\033[1;4;31mF\033[1;4;0mile/\033[1;4;31mQ\033[1;4;0muit] "
        read choice
        case $choice in

                Q|q )
                        exit 0 ;;
                F|f )
                        echo -e "\n"
                        tmp_file=$LOGPATH/$TODAY.tibero.check.log
                        echo " write .. $tmp_file " 
                        echo "--------------------------------------------------------------------" > $tmp_file
                        echo "# 5. Tibero Check                                                   " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file
                        echo "## 5-1. TB Process Cehck                                            " >> $tmp_file
                        echo "" >> $tmp_file
                        echo "${PS_CHECK} " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file
                        echo "${SQL_CHECK} " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file
                        echo "## 5-6. TB syslog Error Check                                       " >> $tmp_file
                        echo "" >> $tmp_file
                        echo "${SYSLOG_CHECK} " >> $tmp_file
                        echo "--------------------------------------------------------------------" >> $tmp_file ;;
                R|r )
                        clear
                        return 0 ;;
        esac
}


# 2023-01-25 Write by G1 ##### 
while ( true ) ; do
  echo "                                            "
  echo "============================================"
  echo " To Check HyperData and Server By TmaxFCPS"
  echo " Hostname is" $HOST
  echo "============================================"
  echo "                                            "
  echo "                                 Write by G1"
  echo "
   Menu's
   ------------------------------------------
    1.  Basic Info + System Mem + CPU
    2.  Disk Check & Mount info
    3.  Network Check & Status
    4.  Kube & HyperData
    5.  HyperData Tibero
    6.  Systemfullog
    q.  Quit

============================================"
  echo -n "                            Select Number : "
  read no
  case $no in 
    "1" )
        basicinfo ;;
    "2" )
        diskcheck ;;
    "3" )     
        networkcheck ;;
    "4" )
        kubecheck ;;
    "5" )
        tiberocheck ;;
    "6" )
        systemfullog ;;
    "q" ) 
        exit 0 ;;
        
   esac
done