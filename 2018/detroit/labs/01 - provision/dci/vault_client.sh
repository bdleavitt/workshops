#!/bin/bash

set +e

VAULT_VOLUME=""
VAULT_SERVER=""

DCI_DIR="${HOME}/.dci"
VAULT_SEALED="true"
VAULT_CONNECTED="false"
VAULT_INIT_PATH="${DCI_DIR}/vault_init.json"
VAULT_KEY_INDEX=0
CLIENT_IN_CONTAINER="false"

#
# Determine if the client is in a container
#

if [ -f "/.dockerenv" ]; then
    CLIENT_IN_CONTAINER="true"
    VAULT_INIT_PATH="/vault/file/vault_init.json"
fi

if [ "${CLIENT_IN_CONTAINER}" = "true" ]; then
    export VAULT_ADDR="http://dci.vault:8200"
else
    export VAULT_ADDR="http://127.0.0.1:8200"
fi

#
# Ensure VAULT_INIT_PATH exists
#
if [ ! -d "${DCI_DIR}" ]; then
    if ! mkdir -p "${DCI_DIR}"; then
        echo "[VAULT] FAIL: Couldn't create ${DCI_DIR} directory"
        return
    fi;
fi;

VAULT_STATUS=$(vault status 2>&1)
EXIT_STATUS=$?

echo "[VAULT] Status Code $EXIT_STATUS"

case "$EXIT_STATUS" in
    "0")
        VAULT_SEALED="false"
        VAULT_CONNECTED="true"
        ;;
    "1")
        VAULT_SEALED="true"
        if ! vault status 2>&1 >/dev/null | grep -q 'connection refused'; then
            VAULT_CONNECTED="true"
            VAULT_OPERATOR_INIT="$(vault operator init --format=json > "${VAULT_INIT_PATH}")"
        else
            VAULT_CONNECTED="false"
        fi;
        ;;
    "2")
        VAULT_SEALED="true"
        VAULT_CONNECTED="true"
        ;;
    *)
        echo "[VAULT] Failed to connect to vault"
        VAULT_CONNECTED="false"
        ;;
esac

#
# Continue to apply keys until the vault is unsealed
#
if [ "${VAULT_CONNECTED}" = "false" ]; then
    echo '[VAULT] FATAL: failed to connect to vault.  Is the server running?'
    echo '[VAULT] Vault is not ready for use'
elif [ "${VAULT_SEALED}" = "true" ] && [ ! -f "${VAULT_INIT_PATH}" ]; then
    echo "[VAULT] FATAL: Missing ${VAULT_INIT_PATH}, cannot unseal vault"
    echo '[VAULT] Vault is not ready for use'
else
    NUM_KEYS="$(jq -r ".unseal_keys_b64 | length" "${VAULT_INIT_PATH}")"

    if [ -z "${NUM_KEYS}" ]; then
        echo "[VAULT] FATAL: No keys found in ${VAULT_INIT_PATH}"
        echo "[VAULT] Vault is not ready for use"
    else
        while [ "${VAULT_SEALED}" = "true" ] && [ "${VAULT_KEY_INDEX}" -lt  "${NUM_KEYS}" ]; do
            NEXT_KEY="$(jq -r ".unseal_keys_b64[${VAULT_KEY_INDEX}]" "${VAULT_INIT_PATH}")"
            VAULT_UNSEAL="$(vault operator unseal "${NEXT_KEY}")"
            VAULT_SEALED="$(vault status --format json | jq '.sealed')"
            VAULT_KEY_INDEX="$((VAULT_KEY_INDEX + 1))"
        done

        #
        # The vault is unsealed, log in with root_token if neceesary
        #

        VAULT_READY="$(if vault operator key-status >/dev/null 2>&1; then echo "true"; else echo "false"; fi)"

        if [ "${VAULT_READY}" = "false" ]; then
            ROOT_TOKEN="$(jq -r ".root_token" "${VAULT_INIT_PATH}")"
            VAULT_LOGIN="$(vault login "${ROOT_TOKEN}" >/dev/null 2>&1)"
            VAULT_READY="true"
        fi
        #
        # The vault is ready to add, read, and remove secrets
        #
        echo "[VAULT] Vault is ready for use"
    fi

fi
