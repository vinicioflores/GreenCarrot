docker cp ./scripts/. config01:/scripts
docker-compose exec config01 sh -c "mongo --host config01 --port 27017 < /scripts/init-configserver.js"

docker cp ./scripts/. sj01:/scripts
docker-compose exec sj01 sh -c "mongo --host sj01 --port 27019 < /scripts/init-repsanjose.js"

docker cp ./scripts/. ca01:/scripts
docker-compose exec ca01 sh -c "mongo --host ca01 --port 27021 < /scripts/init-repcartago.js"

docker cp ./scripts/. al01:/scripts
docker-compose exec al01 sh -c "mongo --host al01 --port 27023 < /scripts/init-repalajuela.js"

docker cp ./scripts/. sj01:/scripts
docker-compose exec sj01 sh -c "mongo --host sj01 --port 27019 < /scripts/init-repsanjose-arbiter.js"

docker cp ./scripts/. ca01:/scripts
docker-compose exec ca01 sh -c "mongo --host ca01 --port 27021 < /scripts/init-repcartago-arbiter.js"

docker cp ./scripts/. al01:/scripts
docker-compose exec al01 sh -c "mongo --host al01 --port 27023 < /scripts/init-repalajuela-arbiter.js"

powershell Start-Sleep -m 20000

docker cp ./scripts/. router01:/scripts
docker-compose exec router01 sh -c "mongo  --port 27028 < /scripts/init-router.js"

docker cp ./scripts/. router02:/scripts
docker-compose exec router02 sh -c "mongo  --port 27029 < /scripts/init-router.js"


docker-compose exec router01 sh -c "mongo --port 27028 < /scripts/mongo_data.js"