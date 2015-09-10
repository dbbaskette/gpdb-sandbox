#!/usr/bin/env bash
source /tmp/release.properties



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
fqdn="$SANDBOX.localdomain"
shortname=\$(echo "\$fqdn" | cut -d "." -f1)
hostsfile=/etc/hosts

cat > "\$hostsfile" <<HOSTS
#This file is automatically genreated on boot; updated at \$(date)
127.0.0.1 localhost.localdomain localhost

\$ip \$fqdn \$shortname
HOSTS

sed -i "/^IP:/ s/$/ \$ip/" /etc/issue
sed -i "s/###/\$ip/g" /etc/issue

EOF

}


setup_message(){

cat > /etc/issue  << 'EOF'
----------------------------------------------------------------------------
Welcome to the Pivotal Greenplum Database - Data Science Sandbox with MADLIB
----------------------------------------------------------------------------
Hostname: \n
IP:
Username: root
Password: pivotal
GPDB Admin: gpadmin
GPDB Password: pivotal
----------------------------------------------------------------------------
                To Run Demos/Tutorials
----------------------------------------------------------------------------
1)  Login as root
2)  Type: demos.sh
----------------------------------------------------------------------------
EOF
}



_main() {
	setup_hostname
	setup_ipaddress
	install_binaries
	setup_data_path
	setup_configs
        setup_gpdb
	setup_message

}



_main "$@"
