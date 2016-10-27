#!/usr/bin/env bash
source /tmp/release.properties




install_zeppelin(){

sudo cp /tmp/bins/$ZEPPELIN_VERSION.tar.gz /usr/local
cd /usr/local
sudo tar xvfz $ZEPPELIN_VERSION.tar.gz
sudo rm -f $ZEPPELIN_VERSION.tar.gz
sudo ln -s /usr/local/$ZEPPELIN_VERSION /usr/local/zeppelin

#cat >> /etc/rc.d/rc.local <<EOF
#/usr/local/$ZEPPELIN_VERSION/bin/zeppelin-daemon.sh start
#EOF
#chmod +x /etc/rc.d/rc.local
# Had a pre-built notebook, but removed
#cp /tmp/configs/notebook.tar.gz /usr/local/$ZEPPELIN_VERSION/notebook
#cd /usr/local/$ZEPPELIN_VERSION/notebook
#tar xvfz notebook.tar.gz
}



_main() {
	install_zeppelin

}



_main "$@"
