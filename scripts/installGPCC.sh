#!/usr/bin/env bash
source /tmp/release.properties




install_gpcc(){
 source /usr/local/greenplum-db/greenplum_path.sh
 source /usr/local/greenplum-cc-web/gpcc_path.sh
 export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
 #echo "host all all 0.0.0.0/0 trust" >> /gpdata/master/gpseg-1/pg_hba.conf
 #echo "host all all 0.0.0.0/0 trust" >> /gpdata/segments/gpseg0/pg_hba.conf
 #gpstop -a -u
 gpperfmon_install --enable --password pivotal --port 5432
 gpstop -a -r
 gpcmdr --setup --config_file /tmp/configs/gpcmdr.conf
 gpstop -a -M fast
}




_main() {
	install_gpcc

}



_main "$@"
