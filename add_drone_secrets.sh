#!/bin/bash
# Script to bootstrap drone.io .drone.yml configuration file based on the values of
# a .drone-values.env file in the projects directory.

DRONE_CLI_PATH="drone"
DRONE_SECRETS_FILE="../infra-aws/ansible/files/compose/infra/drone/.prod.env"
DRONE_VALUES_FILE=".drone_values.env"

# shellcheck source=${DRONE_SECRETS_FILE}
. ${DRONE_SECRETS_FILE}
# shellcheck source=${DRONE_VALUES_FILE}
. ${DRONE_VALUES_FILE}

function add_secret() {
  secret_name=${1}
  secret_value=${2}

  if [[ "${DRONE_SERVER_HOST}" == "" ]]; then
    echo "ERROR: Missing DRONE_URL en var." && exit 1
  fi

  if [[ "${DRONE_TOKEN}" == "" ]]; then
    echo "ERROR: Missing DRONE_TOKEN env var." && exit 1
  fi

  echo "Adding secret: ${secret_name}"
  echo "        Value: ${secret_value}"
  echo
  ${DRONE_CLI_PATH} -s ${DRONE_SERVER_PROTO}://${DRONE_SERVER_HOST} \
                    -t ${DRONE_TOKEN} \
                    secret add \
                    --repository ${DRONE_REPOSITORY_NAME} \
                    --name ${secret_name} \
                    --data "${secret_value}" ${DRONE_REPOSITORY_NAME}
}

function enable_repo (){

  echo "Enabling repo: ${DRONE_REPOSITORY_NAME}"
  
  ${DRONE_CLI_PATH} -s ${DRONE_SERVER_PROTO}://${DRONE_SERVER_HOST} \
                    -t ${DRONE_TOKEN} \
                    repo enable ${DRONE_REPOSITORY_NAME}
}

function add_secrets() {
  # TODO Validar si ya existe el secreto o si quedan duplicados al agregarlos multiples veces
  echo "Adding drone secrets..."
  [ "${DRONE_REGISTRY_USERNAME}" != "" ] && add_secret "docker_username" "${DRONE_REGISTRY_USERNAME}"
  [ "${DRONE_REGISTRY_PASSWORD}" != "" ] && add_secret "docker_password" "${DRONE_REGISTRY_PASSWORD}"
  [ "${SSH_USERNAME}" != "" ] && add_secret "ssh_username" "${SSH_USERNAME}"
  [ "${SSH_KEY}" != "" ] && add_secret "ssh_key" "${SSH_KEY}"
#   [ "${DRONE_SMTP_SERVER}" != "" ] && add_secret "smtp_server" "${DRONE_SMTP_SERVER}"
#   [ "${DRONE_SMTP_PORT}" != "" ] && add_secret "smtp_port" "${DRONE_SMTP_PORT}"
#   [ "${DRONE_SMTP_USERNAME}" != "" ] && add_secret "smtp_username" "${DRONE_SMTP_USERNAME}"
#   [ "${DRONE_SMTP_PASSWORD}" != "" ] && add_secret "smtp_password" "${DRONE_SMTP_PASSWORD}"
  echo "Done."
}

# enable_repo
add_secrets
