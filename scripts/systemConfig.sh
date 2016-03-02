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
		*gemfire*)      gemfire=$justfile
                                strip_ext $justfile
                                echo "GEMFIRE_FILE=$gemfire" >> /tmp/release.properties
                                echo "GEMFIRE_VERSION=$shortname" >> /tmp/release.properties
                                ;;
                *flo*)          flo=$justfile
                                strip_ext $justfile
                                echo "FLO_FILE=$flo" >> /tmp/release.properties
                                echo "FLO_VERSION=$shortname" >> /tmp/release.properties
                                ;;
                spring-xd*)     springxd=$justfile
                                strip_ext $justfile
                                echo "SPRINGXD=$springxd" >> /tmp/release.properties
                                echo "SPRINGXD_VERSION=$shortname" >> /tmp/release.properties
                                ;;
                *maven*)        maven=$justfile
                                strip_ext $justfile
                                echo "MAVEN=$maven" >> /tmp/release.properties
                                echo "MAVEN_VERSION=$shortname" >> /tmp/release.properties
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
        *rpm)           shortname=${1%.rpm};;
 esac


}


setup_vnc(){
	#yum -y install tigervnc tigervnc-server
	echo "VNCSERVERS=\"1:pivotal\"" >> /etc/sysconfig/vncservers
	echo "VNCSERVERARGS[1]=\"-geometry 1024x768\"" >> /etc/sysconfig/vncservers
	chkconfig vncserver on


}

install_gemfire(){
        source /tmp/release.properties
        yum install /tmp/bins/$GEMFIRE_FILE -y
        echo "export locatorHost=pivotal-stack" >> /etc/profile.d/gem.sh
		echo "export locatorPort=10334" >> /etc/profile.d/gem.sh
}


install_maven(){
        source /tmp/release.properties
        tar xvfz /tmp/bins/$MAVEN -C /opt
        echo "export PATH=/opt/${MAVEN_VERSION/-bin/}/bin:\$PATH" >> /etc/profile.d/mavenpath.sh
}

setup_basedirs(){
        echo "source /usr/local/greenplum-db/greenplum_path.sh" >> /etc/profile.d/paths.sh
        echo "export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1" >> /etc/profile.d/paths.sh
        echo "export JAVA_HOME=/usr/lib/jvm/java-openjdk" >> /etc/profile.d/paths.sh
        echo "export PATH=/usr/lib/jvm/java-openjdk/bin:\$PATH" >> /etc/profile.d/paths.sh
}

setup_autologin(){
        mv /tmp/configs/custom.conf /etc/gdm/custom.conf
}


install_binaries(){
source /tmp/release.properties
yum -y install unzip
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
#ip=\$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}')
ip=\$(/sbin/ifconfig | perl -e 'while (<>) { if (/inet +addr:((\d+\.){3}\d+)\s+/ and \$1 ne "127.0.0.1") { \$ip = \$1; break; } } print "\$ip\n"; ' )
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
sed -i "86i host all all \$ip/32 trust" /gpdata/master/gpseg-1/pg_hba.conf

# THIS METHOD ADDED TO END WHICH DIDNT WORK PROPERLT
#echo "host all gpadmin \$ip/32 trust" >> /gpdata/master/gpseg-1/pg_hba.conf

EOF

}

setup_message(){
echo $BUILD_NAME
if [[ $BUILD_NAME = "vmware" ]];then
echo "BUILDING ISSUE for VMWARE"
cat > /etc/issue  << EOF
######
#     # # #    #  ####  #####   ##   #
#     # # #    # #    #   #    #  #  #
######  # #    # #    #   #   ###### #
#       #  #  #  #    #   #   #    # #
#       #   ##    ####    #   #    # ######

 #####
#       #####   ##    #### #    #
#         #    #  #  #     #   #
 #####    #   ###### #     ####
     #    #   #    # #     #   #
 #####    #   #    #  #### #    #
-----------------------------------------------------------------------------
Welcome to the Pivotal Demostack featuring Greenplum DB, Gemfire, & Spring XD
-----------------------------------------------------------------------------
Hostname: \n
IP:
Demo Username: pivotal   Password: pivotal
Root Username: root      Password: pivotal
GPDB Admin: gpadmin      Password: pivotal
Tutorial User:  gpuser   Password: pivotal
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
	setup_vnc
        install_gemfire
        install_maven
        setup_autologin
        setup_basedirs
        setup_data_path
        setup_configs
        setup_gpdb
        setup_message

}


_main "$@"
