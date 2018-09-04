#!/bin/bash

docker-compose exec config01 sh -c "mongo --port 27017 < /scripts/init-configserver.js" # it's primary for the config cluster (2 nodes)

docker-compose exec sj01 sh -c "mongo --port 27018 < /scripts/init-repsanjose.js"
docker-compose exec ca01 sh -c "mongo --port 27019 < /scripts/init-repcartago.js"
docker-compose exec al01 sh -c "mongo --port 27020 < /scripts/init-repalajuela.js"

docker-compose exec sj01 sh -c "mongo --port 27018 < /scripts/init-repsanjose-arbiter.js"
docker-compose exec ca01 sh -c "mongo --port 27019 < /scripts/init-repcartago-arbiter.js"
docker-compose exec al01 sh -c "mongo --port 27020 < /scripts/init-repalajuela-arbiter.js"

sleep 20
docker-compose exec router01 sh -c "mongo < /scripts/init-router.js"
docker-compose exec router02 sh -c "mongo < /scripts/init-router.js"


