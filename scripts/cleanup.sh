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
echo "host all all 0.0.0.0/0 trust" >> /gpdata/master/gpseg-1/pg_hba.conf
echo "host all all 0.0.0.0/0 trust" >> /gpdata/segments/gpseg0/pg_hba.conf

# Clean up the  files
#rm -rf /tmp/configs
#rm -rf /tmp/bins

# BUILD STARTUP SCRIPTS
ip=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
cat > /home/gpadmin/start_all.sh << EOF
source /usr/local/greenplum-db/greenplum_path.sh
source /usr/local/greenplum-cc-web/gpcc_path.sh
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
gpstart -a
gpcmdr --start
sudo /usr/local/$ZEPPELIN_VERSION/bin/zeppelin-daemon.sh start
echo;echo
echo "**********************************************************"
echo " Pivotal Greenplum Database Started on port 5432        "
echo " Pivotal Greenplum Command Center started on port 28080 "
echo "		http://$ip:28080			       "
echo "		Username: gpmon 			       "                    
echo " 		Password: gpmon				       "
echo " Apache Zeppelin started on port 8080		       "
echo "		http://$IP:8080				       "
echo "**********************************************************"
echo;echo
EOF
chown gpadmin: /home/gpadmin/start_all.sh
chmod +x /home/gpadmin/start_all.sh
#clean up hostsfile
sed '$d' /etc/hosts

# Defragment the blocks or else the generated VM image will still be huge
dd if=/dev/zero of=/bigemptyfile bs=4096k
rm -rf /bigemptyfile
