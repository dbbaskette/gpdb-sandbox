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
cp /tmp/configs/notebook.tar.gz /usr/local/$ZEPPELIN_VERSION/notebook
cd /usr/local/$ZEPPELIN_VERSION/notebook
tar xvfz notebook.tar.gz
}



_main() {
	install_zeppelin

}



_main "$@"
