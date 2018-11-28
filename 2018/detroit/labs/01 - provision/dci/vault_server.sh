#!/bin/bash
VAULT_VOLUME=""
VAULT_SERVER=""


usage() {
    echo "Vault Server for Docker Certified Infrastructure"
    echo ""
    echo "Find more information at: https://success.docker.com/architectures#certified-infra"
    echo "Basic Commands:"
    echo "    start          Start a Vault Server locally"
    echo "    status         Check on the Vault Server status"
    echo "    stop           Stop the local Vault Server"
    echo "    help           Print this message"
    echo ""
    echo "vault_server.sh <command>"
    exit 1
}

#
# Volume setup
#
vault_server_start() {
    VAULT_VOLUME="$(docker volume ls --filter 'name=dci.vault' -q)"

    if [ "${VAULT_VOLUME}" = "" ]; then
        VAULT_VOLUME="$(docker volume create dci.vault)"
    fi

    VAULT_CONFIG=$(cat <<END
{
    "backend": {
        "file": {
            "path": "/vault/file"
        }
    },
    "listener": {
        "tcp": {
            "address":"0.0.0.0:8200",
            "tls_disable": 1
        }
    },
    "default_lease_ttl": "168h",
    "max_lease_ttl": "720h"
}
END
)

    #
    # Vault server startup
    #
    VAULT_SERVER="$(docker ps --filter "name=dci.vault" -a -q)"

    if [ -z "${VAULT_SERVER}" ]; then
        VAULT_SERVER="$(docker run -d --name dci.vault \
            --cap-add=IPC_LOCK \
            --restart=always \
            --mount source=dci.vault,target=/vault/file \
            -e "VAULT_LOCAL_CONFIG=${VAULT_CONFIG}" \
            -p 127.0.0.1:8200:8200 \
            vault:0.11.1 server)"
    else
        VAULT_SERVER_STATUS="$(docker inspect "${VAULT_SERVER}" | jq -r ".[0].State.Status")"
        if [ "${VAULT_SERVER_STATUS}" = "exited" ]; then
            VAULT_SERVER_START="$(docker start dci.vault)"
            docker update "${VAULT_SERVER_START}" --restart always > /dev/null
        fi
    fi

    # Just make sure the network is there and the container is connected
    DCI_NETWORK="$(docker network ls --filter name=dci.network -q)"

    if [ -z "${DCI_NETWORK}" ]; then
        docker network create dci.network > /dev/null
    fi;

    VAULT_IN_DCI_NETWORK="$( docker inspect dci.network | jq -r '.[0].Containers[].Name == "dci.vault"')"
    if [ "${VAULT_IN_DCI_NETWORK}" != "true" ]; then
        docker network connect dci.network dci.vault > /dev/null
    fi;

    echo "[VAULT] Vault Server Setup is complete"
}

vault_server_status() {
    VAULT_SERVER="$(docker ps --filter "name=dci.vault" -a -q)"

    if [ ! -z "${VAULT_SERVER}" ]; then
        VAULT_SERVER_STATUS="$(docker inspect "${VAULT_SERVER}" | jq -r ".[0].State.Status")"
        echo "[VAULT] Server is ${VAULT_SERVER_STATUS}"
    else
        echo "[VAULT] Server is not present"
    fi
}


vault_server_stop() {
    VAULT_SERVER="$(docker ps --filter "name=dci.vault" -a -q)"

    if [ ! -z "${VAULT_SERVER}" ]; then
        VAULT_SERVER_STATUS="$(docker inspect "${VAULT_SERVER}" | jq -r ".[0].State.Status")"
        if [ "${VAULT_SERVER_STATUS}" = "running" ]; then
            docker update "${VAULT_SERVER}" --restart no > /dev/null
            docker stop "${VAULT_SERVER}" > /dev/null
        fi
        echo "[VAULT] Server is stopped"
    else
        echo "[VAULT] Server is not present"
    fi
}

if [ "$#" -eq 0 ]; then
    vault_server_start
elif [ "$#" -gt 1 ]; then
    usage
else

    dciMode="$1"

    if [ "${dciMode}" = "start" ]; then
        vault_server_start
    fi

    if [ "${dciMode}" = "status" ]; then
        vault_server_status
    fi

    if [ "${dciMode}" = "stop" ]; then
        vault_server_stop
    fi

    if [ "${dciMode}" = "help" ]; then
        usage
    fi
fi
