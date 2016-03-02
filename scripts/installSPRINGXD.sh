#!/usr/bin/env bash
source /tmp/release.properties




install_sxd(){
 

cp /tmp/bins/$SPRINGXD_VERSION.zip /usr/local
cd /usr/local
unzip $SPRINGXD_VERSION.zip
rm -f $SPRINGXD_VERSION.zip
 
}



_main() {
	install_sxd

}



_main "$@"
