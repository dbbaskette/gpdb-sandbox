#!/bin/bash
cd ../.
mvn install:install-file -Dfile=lib/gemfire-greenplum-1.0.0-beta-6-SNAPSHOT.jar -DgroupId=io.pivotal.gemfire -DartifactId=gemfire-greenplum -Dversion=1.0.0-beta-6-SNAPSHOT -Dpackaging=jar

