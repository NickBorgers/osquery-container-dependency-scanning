all: setup all-finds

setup: bin/osqueryd run-containers

bin/osqueryd:
	docker build -f get_osquery_binary.Dockerfile -t get-os-query-binary .
	mkdir -p ./bin/
	docker run --rm -it \
	  --volume=${CURDIR}/bin/:/app/tmp/:Z \
	  --volume=${CURDIR}/get_osquery_binary.sh:/opt/get_osquery_binary.sh:Z \
	  get-os-query-binary /opt/get_osquery_binary.sh

run-containers: stop-containers
	docker-compose up -d
	# ugly, but ensures the OpenSSL process is running when we pull pids
	sleep 2

stop-containers:
	docker-compose down

all-finds: find-openssl3 find-openssl3-wrapped-distinct find-openssl3-wrapped-groupby find-openssl3-wrapped-limit find-openssl3-wrapped-orderby

find-openssl3:
	sudo bin/osqueryd -S < find_openssl_vulnerability.fancy.sql

find-openssl3-wrapped-distinct:
	-sudo bin/osqueryd -S < find_openssl_vulnerability.fancy.wrapped.distinct.sql

find-openssl3-wrapped-groupby:
	-sudo bin/osqueryd -S < find_openssl_vulnerability.fancy.wrapped.groupby.sql

find-openssl3-wrapped-limit:
	sudo bin/osqueryd -S < find_openssl_vulnerability.fancy.wrapped.limit.sql

find-openssl3-wrapped-orderby:
	-sudo bin/osqueryd -S < find_openssl_vulnerability.fancy.wrapped.orderby.sql
