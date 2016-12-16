#!/usr/bin/env bash
source /tmp/release.properties
set -e

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
                *greenplum-text*) gptext=$justfile
				strip_ext $justfile
                                echo "GPTEXT_FILE=$gptext" >> /tmp/release.properties
                                echo "GPTEXT_VERSION=$shortname" >> /tmp/release.properties
				gptextnum=${gptext:15}
				echo "GPTEXT_VERSION_NUMBER=${gptextnum%%-*}" >>/tmp/release.properties 
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
                *)              echo "UNrecognized File: $justfile"
                                ;;

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
yum -y install unzip

unzip  /tmp/bins/$GPDB_VERSION.zip -d /tmp/bins/
unzip  /tmp/bins/$GPCC_VERSION.zip -d /tmp/bins/
tar -C /tmp/bins/ -zxvf /tmp/bins/$GPTEXT_VERSION.tar.gz 

sed -i 's/more <</cat > \/tmp\/gpdb.lic <</g' /tmp/bins/$GPDB_VERSION.bin
sed -i 's/agreed=/agreed=1/' /tmp/bins/$GPDB_VERSION.bin
sed -i 's/pathVerification=/pathVerification=1/' /tmp/bins/$GPDB_VERSION.bin
sed -i '/defaultInstallPath=/a installPath=${defaultInstallPath}' /tmp/bins/$GPDB_VERSION.bin

sed -i 's/more <</cat > \/tmp\/gpcc.lic <</g' /tmp/bins/$GPCC_VERSION.bin
sed -i 's/agreed=/agreed=1/' /tmp/bins/$GPCC_VERSION.bin
sed -i 's/pathVerification=/pathVerification=1/' /tmp/bins/$GPCC_VERSION.bin
sed -i '/defaultInstallPath=/a installPath=${defaultInstallPath}' /tmp/bins/$GPCC_VERSION.bin

sed -i 's/more <</cat > \/tmp\/gptext.lic <</g' /tmp/bins/$GPTEXT_VERSION.bin
sed -i 's/AGREE=$/AGREE=1/g' /tmp/bins/$GPTEXT_VERSION.bin
sed -i 's/read REPLY LEFTOVER/REPLY=y/g' /tmp/bins/$GPTEXT_VERSION.bin
sed -i "s/read INSTALL_LOC LEFTOVER/INSTALL_LOC=\/usr\/local\/greenplum-text-$GPTEXT_VERSION_NUMBER/g" /tmp/bins/$GPTEXT_VERSION.bin
sed -i 's/pathVerification=/pathVerification=1/' /tmp/bins/$GPTEXT_VERSION.bin
sed -i '/defaultInstallPath=/a installPath=${defaultInstallPath}' /tmp/bins/$GPTEXT_VERSION.bin

/tmp/bins/$GPDB_VERSION.bin 
/tmp/bins/$GPCC_VERSION.bin

echo "Creating Greenplum Text Directories: /usr/local/greenplum-text-$GPTEXT_VERSION_NUMBER"
mkdir /usr/local/greenplum-text-$GPTEXT_VERSION_NUMBER
ln -s /usr/local/greenplum-text-$GPTEXT_VERSION_NUMBER /usr/local/greenplum-text

chown -R gpadmin /usr/local/greenplum*
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
#ip=$(/sbin/ifconfig | perl -e 'while (<>) { if (/inet +addr:((\d+\.){3}\d+)\s+/ and $1 ne "127.0.0.1") { $ip = $1; break; } } print "$ip\n"; ' )
cat > $hostsfile <<HOSTS
#This file is automatically genreated on boot; updated at $(date)
127.0.0.1 localhost.localdomain localhost

$ip $fqdn $shortname
HOSTS

echo $fqdn >> /usr/local/greenplum-db/hostsfile
source /usr/local/greenplum-db/greenplum_path.sh
sed -i "s/%HOSTNAME%/$fqdn/" /tmp/configs/gpinitsystem_singlenode
}

setup_gptext(){

echo "==> Setting up gptext"
cat >> /home/gpadmin/gptext_install_config <<EOF
declare -a DATA_DIRECTORY=(/gpdata/primary /gpdata/primary)
JAVA_OPTS="-Xms1024M -Xmx2048M"
GPTEXT_PORT_BASE=18983
GP_MAX_PORT_LIMIT=28983
ZOO_CLUSTER="BINDING"
declare -a ZOO_HOSTS=(gpdb-sandbox gpdb-sandbox gpdb-sandbox)
ZOO_DATA_DIR="/gpdata/master/"
ZOO_GPTXTNODE="gptext"
ZOO_PORT_BASE=2188
ZOO_MAX_PORT_LIMIT=12188
EOF

}

setup_configs(){

echo "==> Setting up sysctl and limits"
cat /tmp/configs/sysctl.conf.add >> /etc/sysctl.conf
cat /tmp/configs/limits.conf.add >> /etc/security/limits.conf

}

setup_ipaddress() {

rm -rf /etc/udev/rules.d/70-persistent-net.rules
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth*

}

setup_hostname() {

cat >> /etc/rc.d/rc.local <<EOF
if [ ! -f "/home/gpadmin/.skipSetup" ]; then
  ip=\$(/sbin/ifconfig | perl -e 'while (<>) { if (/inet +addr:((\d+\.){3}\d+)\s+/ and \$1 ne "127.0.0.1") { \$ip = \$1; break; } } print "\$ip\n"; ' )
  fqdn="$SANDBOX.localdomain"
  shortname=\$(echo "\$fqdn" | cut -d "." -f1)
  hostsfile=/etc/hosts

  cat > "\$hostsfile" <<HOSTS
  #This file is automatically genreated on boot; updated at \$(date)
  127.0.0.1 localhost.localdomain localhost

  \$ip \$fqdn \$shortname
HOSTS

  # FIX NETWORKING FILE HOSTNAME
  sed -i "s/HOSTNAME=.*/HOSTNAME=gpdb-sandbox.localdomain/g" /etc/sysconfig/network

  # SET HOSTNAME
  hostname gpdb-sandbox.localdomain

  # FIX IP LINE
  sed -i "/IP:/d" /etc/issue
  sed -i "13i IP: \$ip" /etc/issue

  # ADD APPROPRIATE LOCAL IP TO PG_HBA.CONF
  # 	DELETE CURRENT LINE THEN ADD NEW ONE
  sed -i "/192.168/d" /gpdata/master/gpseg-1/pg_hba.conf
  sed -i "86i host all gpadmin \$ip/32 trust" /gpdata/master/gpseg-1/pg_hba.conf
fi
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
Tutorial User:  gpuser     Tutorial User Password: pivotal
-----------------------------------------------------------------------------
                To Start Database, Command Center, and Apache Zeppelin
-----------------------------------------------------------------------------
1)  Login as gpadmin
2)  Type: ./start_all.sh
-----------------------------------------------------------------------------
EOF

elif [[ $BUILD_NAME = "virtualbox" ]];then
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
Tutorial User:  gpuser     Tutorial User Password: pivotal
-----------------------------------------------------------------------------
                To Start Database, Command Center, and Apache Zeppelin
-----------------------------------------------------------------------------
1)  Login as gpadmin
2)  Type: ./start_all.sh
-----------------------------------------------------------------------------
EOF
elif [[ $BUILD_NAME = "docker" ]];then
echo "BUILDING ISSUE for DOCKER"
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
Tutorial User:  gpuser     Tutorial User Password: pivotal
-----------------------------------------------------------------------------
                To Start Database, Command Center, and Apache Zeppelin
-----------------------------------------------------------------------------
1)  Login as gpadmin
2)  Type: ./start_all.sh
-----------------------------------------------------------------------------
EOF
else
echo "BUILDING ISSUE for AWS"
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
         Version:$GPDB_VERSION_NUMBER  - EC2 edition (with PGCRYPTO)
-----------------------------------------------------------------------------
Hostname: \n
Remote SSH:  "ssh gpadmin@localhost"
Username: root
Password: pivotal
GPDB Admin: gpadmin
GPDB Password: pivotal
Tutorial User:  gpuser     Tutorial User Password: pivotal
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
        setup_gptext
	setup_message
}



_main "$@"
