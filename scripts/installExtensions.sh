#!/usr/bin/env bash
source /tmp/release.properties




install_madlib(){
 source /usr/local/greenplum-db/greenplum_path.sh
 export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
 cd /tmp/bins
 tar xvfz $MADLIB_VERSION.tar --strip=1
 gppkg -i madlib*.gppkg 
 $GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c gpadmin@$SANDBOX.localdomain:5432/gpadmin
 echo "INSTALL PL Extensions"
 gppkg -i $PLR_VERSION.gppkg
 createlang plr -d gpadmin
 gppkg -i $PLPERL_VERSION.gppkg
 createlang plperl -d gpadmin
 gppkg -i $PLJAVA_VERSION.gppkg
 gpstop -u
 psql -d gpadmin -f $GPHOME/share/postgresql/pljava/install.sql
 gppkg -i $POSTGIS_VERSION.gppkg
 gpstop -u
 psql -d gpadmin -f $GPHOME/share/postgresql/contrib/postgis-2.0/postgis.sql
}




_main() {
	install_madlib

}



_main "$@"
