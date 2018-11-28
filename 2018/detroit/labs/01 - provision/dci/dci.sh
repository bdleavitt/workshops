#!/bin/bash
set -e
#
# Required parameters
#
DCI_SSH_KEY="${DCI_SSH_KEY:-unknown}"
DCI_CLOUD="${DCI_CLOUD:-unknown}"

#
# Optional parameters
#
DCI_VERSION=${DCI_VERSION:-2.0.0-beta}
DCI_REPOSITORY=${DCI_REPOSITORY-"docker"}
DCI_REFERENCE=${DCI_REFERENCE:-"${DCI_CLOUD}-${DCI_VERSION}"}

#Variables associated with Vault
DCI_VAULT_ANSIBLE_OPTIONS="--extra-vars @/tmp/docker_credentials.yml"
DCI_VAULT_ANSIBLE_SECRETS_CLEANUP="rm -rf /tmp/docker_credentials.yml"
DCI_VAULT_ANSIBLE_SECRETS_FETCH="source ./vault_client.sh; ./fetch_secrets_for_docker.sh"
DCI_VAULT_MOUNT="-v ${HOME}/.dci/vault_init.json:/vault/file/vault_init.json --network=dci.network"
DCI_VAULT_PRESENT="$(docker ps -q --filter 'name=dci.vault')"
DCI_VAULT_TERRAFORM_OPTIONS="-var-file=/tmp/cloud_credentials.auto.tfvars"
DCI_VAULT_TERRAFORM_SECRETS_CLEANUP="rm -rf /tmp/cloud_credentials.auto.tfvars"
DCI_VAULT_TERRAFORM_SECRETS_FETCH=""

usage() {
    echo "Docker Certified Infrastructure"
    echo ""
    echo "Find more information at: https://success.docker.com/architectures#certified-infra"
    echo "Basic Commands:"
    echo "    create         Create a cluster (apply + install)"
    echo "    apply          Apply terraform config"
    echo "    install        Run the install steps"
    echo "    delete         Delete a cluster"
    echo "    help           Print this message"
    echo ""
    echo "dci.sh <command>"
    exit 1
}

determineSecretsToFetch() {
    if [ "${DCI_VAULT_PRESENT}" = "" ]; then
        DCI_VAULT_ANSIBLE_OPTIONS=""
        DCI_VAULT_ANSIBLE_SECRETS_CLEANUP="echo [VAULT] Skipping Cleanup"
        DCI_VAULT_ANSIBLE_SECRETS_FETCH="echo [VAULT] Skipping Fetch"
        DCI_VAULT_MOUNT=""
        DCI_VAULT_TERRAFORM_OPTIONS=""
        DCI_VAULT_TERRAFORM_SECRETS_CLEANUP="echo [VAULT] Skipping Cleanup"
        DCI_VAULT_TERRAFORM_SECRETS_FETCH="echo [VAULT] Skipping Fetch"
        return
    else
        if [ ! -d "${HOME}/.dci" ]; then
            mkdir "${HOME}/.dci"
        fi
        if [ ! -f "${HOME}/.dci/vault_init.json" ]; then
            touch "${HOME}/.dci/vault_init.json"
        fi
    fi


    if [ "${DCI_CLOUD}" = "aws" ] || [ "${DCI_CLOUD}" = "aws-dev" ]; then
        DCI_VAULT_TERRAFORM_SECRETS_FETCH="source ./vault_client.sh; ./fetch_secrets_for_aws.sh"
    fi
    if [ "${DCI_CLOUD}" = "azure" ] || [ "${DCI_CLOUD}" = "azure-dev" ]; then
        DCI_VAULT_TERRAFORM_SECRETS_FETCH="source ./vault_client.sh; ./fetch_secrets_for_azure.sh"
    fi
    if [ "${DCI_CLOUD}" = "gcp" ] || [ "${DCI_CLOUD}" = "gcp-dev" ]; then
        DCI_VAULT_TERRAFORM_SECRETS_FETCH="source ./vault_client.sh; ./fetch_secrets_for_gcp.sh"
        DCI_VAULT_TERRAFORM_SECRETS_CLEANUP="${DCI_VAULT_TERRAFORM_SECRETS_CLEANUP} /tmp/gcp.json"
    fi
    if [ "${DCI_CLOUD}" = "vmware" ] || [ "${DCI_CLOUD}" = "vmware-dev" ]; then
        DCI_VAULT_TERRAFORM_SECRETS_FETCH="source ./vault_client.sh; ./fetch_secrets_for_vmware.sh"
    fi
}

dci_apply() {
    TERRAFORM_OPTIONS="-var 'ssh_private_key_path=/tmp/ssh_private_key' ${DCI_VAULT_TERRAFORM_OPTIONS}"

    docker run -it --rm \
        -v "$(pwd):/dci/${DCI_CLOUD}/" \
        -v "${DCI_SSH_KEY}:/tmp/ssh_private_key:ro" \
        ${DCI_VAULT_MOUNT} \
        "${DCI_REPOSITORY}/certified-infrastructure:${DCI_REFERENCE}" \
        sh -c "${DCI_VAULT_TERRAFORM_SECRETS_FETCH}; \
               terraform init ${TERRAFORM_OPTIONS}; \
               terraform apply -auto-approve ${TERRAFORM_OPTIONS} -parallelism=64; \
               ${DCI_VAULT_TERRAFORM_SECRETS_CLEANUP}"
}

dci_install() {
    TERRAFORM_OPTIONS="-var 'ssh_private_key_path=/tmp/ssh_private_key' ${DCI_VAULT_TERRAFORM_OPTIONS}"

    docker run -it --rm \
        -v "$(pwd):/dci/${DCI_CLOUD}/" \
        -v "${DCI_SSH_KEY}:/tmp/ssh_private_key:ro" \
        ${DCI_VAULT_MOUNT} \
        "${DCI_REPOSITORY}/certified-infrastructure:${DCI_REFERENCE}" \
        sh -c "${DCI_VAULT_ANSIBLE_SECRETS_FETCH}; \
               ansible-playbook ${DCI_VAULT_ANSIBLE_OPTIONS} install.yml; \
               ${DCI_VAULT_ANSIBLE_SECRETS_CLEANUP}"
}

dci_delete() {

    TERRAFORM_OPTIONS="-var 'ssh_private_key_path=/tmp/ssh_private_key' ${DCI_VAULT_TERRAFORM_OPTIONS}"

    docker run -it --rm \
        -v "$(pwd):/dci/${DCI_CLOUD}/" \
        -v "${DCI_SSH_KEY}:/tmp/ssh_private_key:ro" \
        ${DCI_VAULT_MOUNT} \
        "${DCI_REPOSITORY}/certified-infrastructure:${DCI_REFERENCE}" \
        sh -c "${DCI_VAULT_TERRAFORM_SECRETS_FETCH}; \
               terraform init ${TERRAFORM_OPTIONS}; \
               terraform destroy -force ${TERRAFORM_OPTIONS} -parallelism=64; \
               ${DCI_VAULT_TERRAFORM_SECRETS_CLEANUP}"

}

if [ "$#" -ne 1 ]; then
    usage
fi

dciMode="$1"

if [ "${DCI_SSH_KEY}" = "unknown" ]; then
    echo "ERROR: DCI_SSH_KEY not set!"
    echo "Please export an environment variable with the absolute path to the ssh key to login to instances.  Example:"
    echo "  export DCI_SSH_KEY=$HOME/.ssh/id_rsa"
    exit 1;
fi

if [ "${DCI_CLOUD}" = "unknown" ]; then
    echo "ERROR: DCI_CLOUD not set!"
    echo "Please export an environment variable with the cloud you wish to launch.  Example:"
    echo " export DCI_CLOUD=aws"
    echo " export DCI_CLOUD=azure"
    echo " export DCI_CLOUD=vmware"
    exit 1;
fi

if [ ! -f "$(pwd)/terraform.tfvars" ]; then
    echo "ERROR: missing terraform.tfvars"
    echo "Please copy an example from your the DCI examples directory, and personalize it. Example:"
    echo "  cp examples/terraform.tfvars.ubuntu-16.04.example terraform.tfvars"
    exit 1;
fi

determineSecretsToFetch

if [ "${dciMode}" = "create" ]; then
    dci_apply
    dci_install
fi

if [ "${dciMode}" = "apply" ]; then
    dci_apply
fi

if [ "${dciMode}" = "install" ]; then
    dci_install
fi

if [ "${dciMode}" = "delete" ]; then
    dci_delete
fi

if [ "${dciMode}" = "help" ]; then
    usage
fi
