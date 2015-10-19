#!/usr/bin/env bash
source /tmp/release.properties




install_madlib(){
 echo "TEST VARIABLES"
 echo $GPDB_VERSION
 echo $GPDB_FILE
 echo $MADLIB_FILE
 echo $MADLIB_VERSION
 source /usr/local/greenplum-db/greenplum_path.sh
 export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
 cd /tmp/bins
 tar xvfz $MADLIB_FILE --strip=1
 gppkg -i $MADLIB_VERSION.gppkg
 $GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c gpadmin@$SANDBOX.localdomain:5432/gpadmin
 echo "INSTALL PL Extensions"
 gppkg -i $PLR_FILE
 gppkg -i $PLPERL_FILE
 gppkg -i $PLJAVA_FILE
 gppkg -i $POSTGIS_FILE
 source /usr/local/greenplum-db/greenplum_path.sh
 gpstop -r -a 
 psql -d gpadmin -f $GPHOME/share/postgresql/contrib/postgis-2.0/postgis.sql
 createlang plr -d gpadmin
 createlang plperl -d gpadmin
 createlang pljava -d gpadmin
 psql -d gpadmin -f $GPHOME/share/postgresql/pljava/install.sql
}




_main() {
	install_madlib

}



_main "$@"
