all: setup find-openssl3

setup: get-osquery-binary run-containers

get-osquery-binary:
	docker build -f get_osquery_binary.Dockerfile -t get-os-query-binary .
	mkdir -p ./bin/
	docker run --rm -it \
	  --volume=${CURDIR}/bin/:/app/tmp/:Z \
	  --volume=${CURDIR}/get_osquery_binary.sh:/opt/get_osquery_binary.sh:Z \
	  get-os-query-binary /opt/get_osquery_binary.sh

run-containers: stop-containers
	docker-compose up -d

stop-containers:
	docker-compose down

find-openssl3:
	sudo bin/osqueryd -S < find_openssl_vulnerability.sql
