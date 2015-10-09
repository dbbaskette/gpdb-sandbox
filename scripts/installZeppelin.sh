#!/usr/bin/env bash
source /tmp/release.properties




install_zeppelin(){

cp /tmp/bins/$ZEPPELIN_VERSION.tar.gz /usr/local
cd /usr/local
tar xvfz $ZEPPELIN_VERSION.tar.gz
rm -f $ZEPPELIN_VERSION.tar.gz

#cat >> /etc/rc.d/rc.local <<EOF
#/usr/local/$ZEPPELIN_VERSION/bin/zeppelin-daemon.sh start
#EOF
#chmod +x /etc/rc.d/rc.local
}





_main() {
	install_zeppelin

}



_main "$@"
