#!/usr/bin/env bash
source /tmp/release.properties
get_versions(){
shopt -s nullglob
echo $BUILD_NAME Build Started
for filename in /tmp/bins/*
do
	justfile=${filename:10}
        case $justfile in
                *greenplum-db*) gpdb=$justfile
				strip_ext $justfile
				echo "GPDB_FILE=$gpdb" >> /tmp/release.properties
				echo "GPDB_VERSION=$shortname" >> /tmp/release.properties
				gpdbnum=${gpdb:13}
				echo "GPDB_VERSION_NUMBER=${gpdbnum%%-*}" >>/tmp/release.properties 
				;;
                *greenplum-cc*) gpcc=$justfile
				strip_ext $justfile
                                echo "GPCC_FILE=$gpcc" >> /tmp/release.properties
                                echo "GPCC_VERSION=$shortname" >> /tmp/release.properties
                                ;;

                *madlib*)       madlib=$justfile
				strip_ext $justfile
                                echo "MADLIB_FILE=$madlib" >> /tmp/release.properties
                                echo "MADLIB_VERSION=$shortname" >> /tmp/release.properties
				;;
                *pljava*)       plj=$justfile
        			strip_ext $justfile
                                echo "PLJAVA_FILE=$plj" >> /tmp/release.properties
                                echo "PLJAVA_VERSION=$shortname" >> /tmp/release.properties
				;;
                *plperl*)       plpr=$justfile
        			strip_ext $justfile
                                echo "PLPERL_FILE=$plpr" >> /tmp/release.properties
                                echo "PLPERL_VERSION=$shortname" >> /tmp/release.properties
				;;
                *plr*)          plr=$justfile
        			strip_ext $justfile
                                echo "PLR_FILE=$plr" >> /tmp/release.properties
                                echo "PLR_VERSION=$shortname" >> /tmp/release.properties
				;;
                *zeppelin*)     zepp=$justfile
        			strip_ext $justfile
				echo $zepp
				echo $shortname
                                echo "ZEPPELIN_FILE=$zepp" >> /tmp/release.properties
                                echo "ZEPPELIN_VERSION=$shortname" >> /tmp/release.properties
				;;
                *postgis*)      post=$justfile
        			strip_ext $justfile
                                echo "POSTGIS_FILE=$post" >> /tmp/release.properties
                                echo "POSTGIS_VERSION=$shortname" >> /tmp/release.properties
				;;
		*pgcrypto*)     pgcrypto=$justfile
                                strip_ext $justfile
                                echo "PGCRYPTO_FILE=$pgcrypto" >> /tmp/release.properties
                                echo "PGCRYPTO_VERSION=$shortname" >> /tmp/release.properties
                                ;;


                *)              echo "UNrecognized File: $justfile";exit;;

        esac
done
}


strip_ext(){
 case ${1##*.} in
        *gppkg)        shortname=${1%.gppkg};;
        *zip)          shortname=${1%.zip};;
        *tar)          shortname=${1%.tar};;
        *gz)           shortname=${1%.tar.gz};;
 esac


}


install_binaries(){
source /tmp/release.properties
unzip  /tmp/bins/$GPDB_VERSION.zip -d /tmp/bins
unzip  /tmp/bins/$GPCC_VERSION.zip -d /tmp/bins

sed -i s/"more << EOF"/"cat << EOF"/g /tmp/bins/$GPDB_VERSION.bin
sed -i s/"more << EOF"/"cat << EOF"/g /tmp/bins/$GPCC_VERSION.bin
sed -i s/"more <<-EOF"/"cat <<-EOF"/g /tmp/bins/$GPCC_VERSION.bin

/tmp/bins/$GPDB_VERSION.bin << EOF
yes

yes
yes
EOF
/tmp/bins/$GPCC_VERSION.bin << EOF
yes

yes
yes
EOF

chown -R gpadmin: /usr/local/greenplum*

}

setup_data_path(){

mkdir -p /gpdata/master
mkdir -p /gpdata/segments
chown -R gpadmin: /gpdata
}

setup_gpdb(){
fqdn="$SANDBOX.localdomain"
hostsfile="/etc/hosts"
shortname=$(echo "$fqdn" | cut -d "." -f1)
ip=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
# JON ROBERTS IP FIX
#adapter=`ifconfig  | grep Link | grep Ethernet | awk -F ' ' '{print $1}'`
#ip=`ifconfig $adapter | grep "inet addr" | awk -F ' ' '{print $2}' | awk -F ':' '{print $2}'`
cat > $hostsfile <<HOSTS
#This file is automatically genreated on boot; updated at $(date)
127.0.0.1 localhost.localdomain localhost

$ip $fqdn $shortname
HOSTS
 echo $fqdn >> /usr/local/greenplum-db/hostsfile
 source /usr/local/greenplum-db/greenplum_path.sh
 sed -i "s/%HOSTNAME%/$fqdn/" /tmp/configs/gpinitsystem_singlenode
}


setup_configs(){

cat /tmp/configs/sysctl.conf.add >> /etc/sysctl.conf
cat /tmp/configs/limits.conf.add >> /etc/security/limits.conf

}

setup_ipaddress() {
rm -rf /etc/udev/rules.d/70-persistent-net.rules
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
}

setup_hostname() {
cat >> /etc/rc.d/rc.local <<EOF
ip=\$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}')
# JON ROBERTS IP FIX
#adapter=`ifconfig  | grep Link | grep Ethernet | awk -F ' ' '{print \$1}'`
#ip=`ifconfig \$adapter | grep "inet addr" | awk -F ' ' '{print \$2}' | awk -F ':' '{print \$2}'`
fqdn="$SANDBOX.localdomain"
shortname=\$(echo "\$fqdn" | cut -d "." -f1)
hostsfile=/etc/hosts

cat > "\$hostsfile" <<HOSTS
#This file is automatically genreated on boot; updated at \$(date)
127.0.0.1 localhost.localdomain localhost

\$ip \$fqdn \$shortname
HOSTS

# FIX IP LINE
sed -i "/IP:/d" /etc/issue
sed -i "13i IP: \$ip" /etc/issue
#sed -i "/^IP:/ s/$/ \$ip/" /etc/issue
#sed -i "s/Version:/Version: $GPDB_VERSION_NUMBER/g" /etc/issue
#sed -i "s/@@@/\$ip/g" /etc/issue


# ADD APPROPRIATE LOCAL IP TO PG_HBA.CONF
# 	DELETE CURRENT LINE THEN ADD NEW ONE
sed -i "/192.168/d" /gpdata/master/gpseg-1/pg_hba.conf
sed -i "86i host all gpadmin \$ip/32 trust" /gpdata/master/gpseg-1/pg_hba.conf

# THIS METHOD ADDED TO END WHICH DIDNT WORK PROPERLT
#echo "host all gpadmin \$ip/32 trust" >> /gpdata/master/gpseg-1/pg_hba.conf

EOF

}


setup_message(){
echo $BUILD_NAME
if [[ $BUILD_NAME = "vmware" ]];then
echo "BUILDING ISSUE for VMWARE"
cat > /etc/issue  << EOF
                                     ##                             
  ###                                 #                  ####  #### 
 #    ## ##  ###   ###  ####   ###    #   # #  #####      # #   # # 
## #   ## # ##### #####  # ##  # ##   #   # #  # # ##    #  #  ###  
## #   #    ##    ##     # #   # #   ##   # #  # # #     # ##  # ## 
 ###  ###    ###   ###  ## ##  ##   ####  #### # # #    ####  ####  
                              ###     
-----------------------------------------------------------------------------
Welcome to the Pivotal Greenplum DB - Data Science Sandbox with Apache MADLIB
	 Version:$GPDB_VERSION_NUMBER   - vmware edition (with PGCRYPTO)
-----------------------------------------------------------------------------
Hostname: \n
IP:
Username: root
Password: pivotal
GPDB Admin: gpadmin
GPDB Password: pivotal

-----------------------------------------------------------------------------
                To Start Database, Command Center, and Apache Zeppelin
-----------------------------------------------------------------------------
1)  Login as gpadmin
2)  Type: ./start_all.sh
-----------------------------------------------------------------------------
EOF

else
echo "BUILDING ISSUE for VBOX"
cat > /etc/issue  << EOF
                                     ##
  ###                                 #                  ####  ####
 #    ## ##  ###   ###  ####   ###    #   # #  #####      # #   # #
## #   ## # ##### #####  # ##  # ##   #   # #  # # ##    #  #  ###
## #   #    ##    ##     # #   # #   ##   # #  # # #     # ##  # ##
 ###  ###    ###   ###  ## ##  ##   ####  #### # # #    ####  ####
                              ###
-----------------------------------------------------------------------------
Welcome to the Pivotal Greenplum DB - Data Science Sandbox with Apache MADLIB
         Version:$GPDB_VERSION_NUMBER  - vbox edition (with PGCRYPTO)
-----------------------------------------------------------------------------
Hostname: \n
Remote SSH:  "ssh gpadmin@localhost -p 2200"
Username: root
Password: pivotal
GPDB Admin: gpadmin
GPDB Password: pivotal

-----------------------------------------------------------------------------
                To Start Database, Command Center, and Apache Zeppelin
-----------------------------------------------------------------------------
1)  Login as gpadmin
2)  Type: ./start_all.sh
-----------------------------------------------------------------------------
EOF


fi



}



_main() {
	get_versions
	setup_hostname
	setup_ipaddress
	install_binaries
	setup_data_path
	setup_configs
        setup_gpdb
	setup_message

}



_main "$@"
