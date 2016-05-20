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
 tar xvfz $MADLIB_FILE 
 gppkg -i $MADLIB_VERSION.gppkg
 $GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c gpadmin@$SANDBOX.localdomain:5432/template1
 $GPHOME/madlib/bin/madpack install -s madlib -p greenplum -c gpadmin@$SANDBOX.localdomain:5432/gpadmin
 echo "INSTALL PL Extensions"
 gppkg -i $PLR_FILE
 gppkg -i $PLPERL_FILE
 gppkg -i $PLJAVA_FILE
 gppkg -i $POSTGIS_FILE
 source /usr/local/greenplum-db/greenplum_path.sh
 gpstop -r -a 
 psql -d template1 -f $GPHOME/share/postgresql/contrib/postgis-2.0/postgis.sql
 createlang plr -d template1
 createlang plperl -d template1
 createlang pljava -d template1
 psql -d template1 -f $GPHOME/share/postgresql/pljava/install.sql
 psql -d gpadmin -f $GPHOME/share/postgresql/contrib/postgis-2.0/postgis.sql
 createlang plr -d  gpadmin
 createlang plperl -d gpadmin
 createlang pljava -d gpadmin
 psql -d gpadmin -f $GPHOME/share/postgresql/pljava/install.sql
}

install_pgcrypto(){
 gppkg -i $PGCRYPTO_FILE 
 psql -d template1 -f $GPHOME/share/postgresql/contrib/pgcrypto.sql 
 psql -d gpadmin -f $GPHOME/share/postgresql/contrib/pgcrypto.sql 
 echo "source /home/gpadmin/gp-wlm/gp-wlm_path.sh" >> /home/gpadmin/.bashrc
}

install_plcontainer(){
 gppkg -i $PLCONTAINER_FILE
 psql -f $GPHOME/share/postgresql/plcontainer/plcontainer_install.sql -d template1
 psql -f $GPHOME/share/postgresql/plcontainer/plcontainer_install.sql -d gpadmin
 plcontainer-config --reset
 docker pull pivotaldata/plcontainer_python:0.1.1-1
 docker pull pivotaldata/plcontainer_python_shared:0.1.1-1
 docker pull pivotaldata/plcontainer_anaconda:0.1.1-1
 docker pull pivotaldata/plcontainer_r:0.1.1-1
 docker pull pivotaldata/plcontainer_r_shared:0.1.1-1
 }

_main() {
	install_madlib
	install_pgcrypto
        install_plcontainer
}



_main "$@"
