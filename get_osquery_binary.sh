#!/bin/bash

wget -O /tmp/osquery.deb https://github.com/osquery/osquery/releases/download/5.8.1/osquery_5.8.1-1.linux_amd64.deb
cd /tmp/
ar x osquery.deb
tar -xvf data.tar.gz
cp /tmp/opt/osquery/bin/osqueryd /app/tmp/