#!/usr/bin/env bash
source /tmp/release.properties



install_demo(){
	whoami
	cp -R /tmp/FraudDetection-wwko ~/.
	#mkdir ~/Desktop ~/.vnc
	echo -e "pivotal\npivotal\n" | vncpasswd
	
	cp /tmp/configs/*.desktop ~/Desktop/.
	echo "exec gnome-session &" > ~/.vnc/xstartup
	chmod 755 ~/.vnc/xstartup

	# BUILD GEMFIRE
	cd /home/pivotal/FraudDetection-wwko
	export PATH=/opt/${MAVEN_VERSION/-bin/}/bin:$PATH
	mvn install:install-file -Dfile=lib/gemfire-greenplum-1.0.0-beta-6-SNAPSHOT.jar -DgroupId=io.pivotal.gemfire -DartifactId=gemfire-greenplum -Dversion=1.0.0-beta-6-SNAPSHOT -Dpackaging=jar
	cd Server

	./gradlew serverJar
	
	#BUILD GUI
	export locatorHost=pivotal-stack
	export locatorPort=10334
	mvn install:install-file -Dfile=lib/gemfire-greenplum-1.0.0-beta-6-SNAPSHOT.jar -DgroupId=io.pivotal.gemfire -DartifactId=gemfire-greenplum -Dversion=1.0.0-beta-6-SNAPSHOT -Dpackaging=jar
	cd ../WebConsole
	./gradlew jar
	
	#BUILD STARTUP
	echo "echo Starting Greenplum Database" >  ~/start_data.sh
	echo "echo pivotal | sudo -S -u gpadmin /home/gpadmin/start_all.sh" >> ~/start_data.sh 
	echo "echo Starting Gemfire In-Memory DataGrid" >>  ~/start_data.sh
	echo "cd /home/pivotal/FraudDetection-wwko/Server" >> ~/start_data.sh
	echo "./startup.sh" >> ~/start_data.sh
	echo "read -n1 -r -p /"Press space to continue.../"" key
	
	chmod +x ~/start_data.sh
	
	
	

 
}




_main() {
	install_demo

}



_main "$@"
