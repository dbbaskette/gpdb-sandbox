#!/bin/bash

# Setup up tables in Greenplum DB for Lab/Demo
echo "Setting up Greenplum Tables"
echo "---------------------------"
psql -d gemfire -f $GPHOME/share/postgresql/contrib/postgis-2.0/postgis.sql
psql -d gemfire -f /home/pivotal/FraudDetection-wwko/Server/scripts/model.sql
echo "---------------------------"
echo "Grennplum Setup is complete"

