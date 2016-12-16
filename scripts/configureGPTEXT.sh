#!/usr/bin/env bash
source /tmp/release.properties

configure_gptext(){

source /usr/local/greenplum-db/greenplum_path.sh
source /usr/local/greenplum-cc-web/gpcc_path.sh
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1

cp /tmp/bins/$GPTEXT_VERSION.bin /home/gpadmin/

# skipping installation of gptext at this point 
#wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.rpm
#sudo rpm --install jdk-8u112-linux-x64.rpm
#rm -rf /usr/local/greenplum-db/ext/jre*
#ln -s /usr/java/latest/jre /usr/local/greenplum-db/ext/jre
#
#gpstart -a
#/home/gpadmin/$GPTEXT_VERSION.bin -c /home/gpadmin/gptext_install_config
#gpstop -M fast -a
}

_main() {
	configure_gptext
}

_main "$@"
