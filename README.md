# mongo-replica-set

An easy to use docker image to setup replica set via docker-compose.yml.

Available on docker hub https://hub.docker.com/r/heyarny/mongo-replica-set

## docker-compose


```yml
version: '3.7'

services:

  # mongodb
  mongo1:
    image: mongo:3.6
    volumes:
      - ./data_db:/data/db
    entrypoint: [ "/usr/bin/mongod", "--bind_ip_all", "--replSet", "rs0" ]
    ports:
      - 27020:27017
    restart: always

  mongo_replica_setup:
    image: heyarny/mongo-replica-set:latest
    depends_on:
      - mongo1
    environment:
      MONGO_HOSTS: mongo1
      MONGO_REPLSET: rs0

```

**MONGO_HOSTS** = one or more references to mongodb containers separated by space.

**MONGO_REPLSET** = name of the replica set

## License
[WTFPL](https://en.wikipedia.org/wiki/WTFPL)
