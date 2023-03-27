get-osquery-binary:
	docker build -f get_osquery_binary.Dockerfile -t get-os-query-binary .
	mkdir -p ./bin/
	docker run --rm -it \
	  --volume=${CURDIR}/bin/:/app/tmp/ \
	  --volume=${CURDIR}/get_osquery_binary.sh:/opt/get_osquery_binary.sh \
	  get-os-query-binary /opt/get_osquery_binary.sh

run-containers:
	docker-compose up -d