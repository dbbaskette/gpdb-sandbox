#!/usr/bin/env bash
source /tmp/release.properties




install_gpdb(){
 source /usr/local/greenplum-db/greenplum_path.sh
 /usr/local/greenplum-db/bin/gpssh-exkeys -f /usr/local/greenplum-db/hostsfile
 gpinitsystem -a -c  /tmp/configs/gpinitsystem_singlenode -h /usr/local/greenplum-db/hostsfile
 echo "INSTALLED"
 # gpstart -a
 createdb gpadmin
 echo "host all all 0.0.0.0/0 trust" >> /gpdata/master/gpseg-1/pg_hba.conf

gpstop -u
 #gpstop -M smart

# ADD DEMO STUFF

psql -c "create user pivotal with superuser login;"
psql -c "alter role pivotal with password 'pivotal';"
createdb gemfire
psql -c "grant all on database gemfire to pivotal;"


}


tutorial_repo(){
 echo "No Tutorial"        
#git clone --depth=1 https://github.com/Pivotal-Open-Source-Hub/gpdb-sandbox-tutorials.git
}




_main() {
	install_gpdb
	tutorial_repo

}



_main "$@"
