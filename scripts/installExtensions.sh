#!/usr/bin/env bash
source /tmp/release.properties




install_madlib(){
 source /usr/local/greenplum-db/greenplum_path.sh
 export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
 tar xvfz /tmp/bins/$MADLIB_VERSION.tar --strip=1
 gppkg -i madlib*.gppkg 
 $GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c gpadmin@$SANDBOX.localdomain:5432/gpadmin
 echo "INSTALL PL Extensions"
 gppkg -i $PLR_VERSION.gppkg
 gppkg -i $PLPERL_VERSION.gppkg
 gppkg -i $PLJAVA_VERSION.gppkg
 gppkg -i $POSTGIS_VERSION.gppkg
}




_main() {
	install_madlib

}



_main "$@"
