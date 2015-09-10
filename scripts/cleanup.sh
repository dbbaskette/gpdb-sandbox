#!/usr/bin/env bash

#
# used to cleanup image from all things needed by tools to deploy
# image should be only Pivotal software
#

set -x
set -o pipefail

set

# Add Entry tp pg_hba.conf to open up access
echo "host all all 0.0.0.0/0 trust" >> /gpdata/master/gpseg-1/pg_hba.conf
echo "host all all 0.0.0.0/0 trust" >> /gpdata/segments/gpseg0/pg_hba.conf

# Clean up the  files
rm -rf /tmp/configs
rm -rf /tmp/bins


#clean up hostsfile
sed '$d' /etc/hosts

# Defragment the blocks or else the generated VM image will still be huge
dd if=/dev/zero of=/bigemptyfile bs=4096k
rm -rf /bigemptyfile
