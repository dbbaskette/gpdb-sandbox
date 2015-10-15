#!/usr/bin/env bash
source /tmp/release.properties

get_versions(){
echo "GET VERSIONS!"
shopt -s nullglob
for filename in /tmp/bins/*
do
	echo $filename
	echo ${filename:10}
        case ${filename:10} in
                *greenplum-db*) gpdb=${filename:10};;
                *greenplum-cc*) gpcc=${filename:10};;
                *madlib*)       madlib=${filename:10};;
                *pljava*)       plj=${filename:10};;
                *plperl*)       plpr=${filename:10};;
                *plr*)          plr=${filename:10};;
                *zeppelin*)     zepp=${filename:10};;
                *postgis*)      post=${filename:10};;
                *notebook*)     note=${filename:10};;
                *)              echo "UNrecognized File: ${filename:10}";exit;;

        esac
done

echo ${gpdb:13}
gpdbv=${gpdb:13}
echo ${gpdbv%%-*}
export gpdbversion=${gpdbv%%-*}
echo $gpdbversion
}

install_binaries(){
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

sed -i "/^IP:/ s/$/ \$ip/" /etc/issue
#sed -i "s/Version:/Version: $gpdbversion/g" /etc/issue
#sed -i "s/@@@/\$ip/g" /etc/issue

EOF

}


setup_message(){

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
			 Version:$gpdbversion
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
