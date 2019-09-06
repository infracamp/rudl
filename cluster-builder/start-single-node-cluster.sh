#!/bin/bash


set -ex


CONF_CLUSTER_NAME=$1
CONF_REPO_URL=$2



STACK=$(cat <<EOF

version: "3.7"
services:
  rudl-cloudfront:
    image: infracamp/rudl-cloudfront
    deploy:
      mode: global
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: host
      - target: 443
        published: 443
        protocol: tcp
        mode: host
    networks:
      - rudl-cf-net
      - rudl-principal-net
    secrets:
      - rudl_cf_secret

  rudl-principal:
    image: infracamp/rudl-principal
    deploy:
      placement:
        constraints: [node.role == manager]
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "rudl-principal:/mnt"
    networks:
      - rudl-principal-net
    environment:
      - "CONF_CLUSTER_NAME=$CONF_CLUSTER_NAME"
      - "CONF_REPO_URL=$CONF_REPO_URL"
    secrets:
      - rudl_cf_secret
      - rudl_principal_secret

volumes:
  rudl-principal:

secrets:
  rudl_cf_secret:
    external: true

networks:
  rudl-cf-net:
    external: true

  rudl-principal-net:
    external: false

EOF
);



if [[ $(docker info | grep "Swarm: active") != "" ]]
then
    IS_SWARM=1
else
    IS_SWARM=0
fi


if [[ $IS_SWARM == 0 ]]
then
    echo "Not a swarm Member - Initializing swarm"
    docker swarm init

    if [[ $(docker network ls | grep rudl-cf-net) == "" ]]
    then
         docker network create --attachable --driver overlay rudl-cf-net
    fi;

    pwgen 64 -s -1 | docker secret create rudl_cf_secret -
    pwgen 64 -s -1 | docker secret create rudl_principal_secret -

    echo "$STACK" | docker stack deploy rudl -c -

else
    echo "already swarm member"

fi;


