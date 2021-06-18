#!/bin/bash
DEBUG="${DEBUG:-0}"
[ $DEBUG -eq 1 ] && set -x && env

set -Eeo pipefail
_traperr() {
  echo "ERROR: ${BASH_SOURCE[1]} at about line ${BASH_LINENO[0]}"
  docker logout $CI_REGISTRY
}
trap _traperr ERR

REGISTRY_HOST="docker.io"
REGISTRY_USER="juanluisbaptiste"
MOUNT_POINT="/mnt/efs/web-prod/sites/timeoff/"
STACK_FILE="stack.yml"
STACK_NAME="${1}"

[[ -z "${STACK_NAME}"  ]] && echo "ERROR: No stack name set" && exit 1
#[[ -z "${REGISTRY_PASSWORD}"  ]] && echo "ERROR: No docker registry password set" && exit 1


#docker login ${REGISTRY_HOST} -u ${REGISTRY_USERNAME} -p ${REGISTRY_PASSWORD}
echo "Removing previous deployment of application: ${STACK_NAME} ..."
docker stack rm ${STACK_NAME}

echo "Deploying application: ${STACK_NAME} ..."
mkdir -p ${MOUNT_POINT}
sudo touch ${MOUNT_POINT}/db.development.sqlite
sudo chown 100 ${MOUNT_POINT}/db.development.sqlite
sudo chmod 664 ${MOUNT_POINT}/db.development.sqlite
sleep 1

docker stack deploy --with-registry-auth -c ${STACK_FILE} ${STACK_NAME}

if [ $DEBUG -eq 1 ]; then
  sleep 5
  docker stack ps --no-trunc ${STACK_NAME}
fi