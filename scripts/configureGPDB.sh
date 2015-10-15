#!/usr/bin/env bash
source /tmp/release.properties




configure_gpdb(){
source /usr/local/greenplum-db/greenplum_path.sh
 cat >> /home/gpadmin/.bashrc << EOF
source /usr/local/greenplum-db/greenplum_path.sh
source /usr/local/greenplum-cc-web/gpcc_path.sh
export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1
EOF
}


_main() {
	configure_gpdb

}



_main "$@"
