#!/usr/bin/env bash

#
# used to cleanup image from all things needed by tools to deploy
# image should be only Pivotal software
#

set -x
set -o pipefail

set
source /tmp/release.properties

# Add Entry tp pg_hba.conf to open up access
echo "local    tutorial            +users     md5" >> /gpdata/master/gpseg-1/pg_hba.conf
echo "local    gemfire pivotal trust" >> /gpdata/master/gpseg-1/pg_hba.conf
echo "host all all 0.0.0.0/0 md5" >> /gpdata/master/gpseg-1/pg_hba.conf

# REMOVE OPEN LINE FOR BUILD VM
sed -i "/192.168/d" /gpdata/master/gpseg-1/pg_hba.conf


echo "host all all 0.0.0.0/0 trust" >> /gpdata/segments/gpseg0/pg_hba.conf
echo "host all all 0.0.0.0/0 trust" >> /gpdata/segments/gpseg1/pg_hba.conf

# Clean up the  files
#rm -rf /tmp/configs
#rm -rf /tmp/bins

# BUILD START/STOP SCRIPTS

if [[ $BUILD_NAME = "vmware" ]]; then
echo "BUILD for VMWARE"

cat > /home/gpadmin/start_all.sh << EOF
echo "*********************************************************************************"
echo "* Script starts the Greenplum DB, Greenplum Control Center, and Apache Zeppelin *"
echo "*********************************************************************************"
echo "* Starting Greenplum Database..."
ip=\$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}')
source /usr/local/greenplum-db/greenplum_path.sh
source /usr/local/greenplum-cc-web/gpcc_path.sh
source /home/gpadmin/gp-wlm/gp-wlm_path.sh
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
gpstart -a
echo "* Greenplum Database Started."
echo "* Starting Greenplum Command Center..."
gpcmdr --start
svc-mgr.sh --action=cluster-start --service=all
echo "* Greenplum Command Center Started."
echo "* Starting Apache Zeppelin Server...."
sudo /usr/local/$ZEPPELIN_VERSION/bin/zeppelin-daemon.sh start
echo "* Apache Zeppelin Server Started."
echo "*********************************************************************************"
echo " Pivotal Greenplum Database Started on port 5432        "
echo " Pivotal Greenplum Command Center started on port 28080 "
echo "		http://\$ip:28080			       "
echo "		Username: gpmon 			       "                    
echo " 		Password: pivotal			       "
echo " Apache Zeppelin started on port 8080		       "
echo "		http://\$ip:8080				       "
echo "*********************************************************************************"
echo;echo
EOF
else
echo "BUILD for VBOX"
cat > /home/gpadmin/start_all.sh << EOF
echo "*********************************************************************************"
echo "* Script starts the Greenplum DB, and Apache Zeppelin *"
echo "*********************************************************************************"
echo "* Starting Greenplum Database..."
source /usr/local/greenplum-db/greenplum_path.sh
#source /usr/local/greenplum-cc-web/gpcc_path.sh
#source /home/gpadmin/gp-wlm/gp-wlm_path.sh
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
gpstart -a
echo "* Greenplum Database Started."
#echo "* Starting Greenplum Command Center..."
#gpcmdr --start
#echo "* Greenplum Command Center Started."
echo "* Starting Apache Zeppelin Server...."
sudo /usr/local/$ZEPPELIN_VERSION/bin/zeppelin-daemon.sh start
echo "* Apache Zeppelin Server Started."
echo "*********************************************************************************"
echo "* Updating Tutorial Files..."
cd ~/gpdb-sandbox-tutorials;git pull > /dev/null 2>&1;tar xvfz faa.tar.gz;cd
echo "* Tutorials Updated."
echo "*********************************************************************************"
echo " Pivotal Greenplum Database Started on port 5432        "
#echo " Pivotal Greenplum Command Center started on port 28080 "
#echo "          http://localhost:28080                              "
#echo "          Username: gpmon                                "
#echo "          Password: pivotal                              "
echo " Apache Zeppelin started on port 8081                    "
echo "          http://localhost:8081                                       "
echo "*********************************************************************************"
echo;echo
EOF


fi


cat > /home/gpadmin/stop_all.sh << EOF

echo "********************************************************************************************"
echo "* This script stops the Greenplum Database, Greenplum Control Center, and Apache Zeppelin *"
echo "********************************************************************************************"
echo "* Stopping Greenplum Database..."
source /usr/local/greenplum-db/greenplum_path.sh
source /usr/local/greenplum-cc-web/gpcc_path.sh
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
gpstop -M immediate -a
echo "* Greenplum Database Stopped."
echo "* Stoppin Greenplum Command Center..."
gpcmdr --stop
echo "* Greenplum Command Center Stopped."
echo "* Stopping Apache Zeppelin Server...."
sudo /usr/local/$ZEPPELIN_VERSION/bin/zeppelin-daemon.sh stop
echo "* Apache Zepeelin Server Stopped."
echo "********************************************************************************************"
echo " ALL DATABASE RELATED SERVICES STOPPED.    RUN ./start_all.sh to restart"
echo "********************************************************************************************"
echo;
EOF


# ENABLE NTP
chkconfig ntpd on

chown gpadmin: /home/gpadmin/start_all.sh
chmod +x /home/gpadmin/start_all.sh
chown gpadmin: /home/gpadmin/stop_all.sh
chmod +x /home/gpadmin/stop_all.sh
#clean up hostsfile
sed '$d' /etc/hosts

# CLEAN UP
rm -f /home/gpadmin/VBoxGuestAdditions.iso
rm -rf /tmp/bins
rm -rf /tmp/configs

# Defragment the blocks or else the generated VM image will still be huge

dd if=/dev/zero of=/bigemptyfile bs=4096k
rm -rf /bigemptyfile
