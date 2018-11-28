#!/bin/bash
{
    echo '---'
    echo dev_registry_username: \""$(vault kv get -field username secret/docker)"\"
    echo dev_registry_password: \""$(vault kv get -field password secret/docker)"\"
    echo docker_hub_id: \""$(vault kv get -field username secret/docker)"\"
    echo docker_hub_password: \""$(vault kv get -field password secret/docker)"\"
    echo docker_ee_subscriptions_ubuntu: \""$(vault kv get -field subscriptions_ubuntu secret/docker)"\"
    echo docker_ee_subscriptions_centos: \""$(vault kv get -field subscriptions_centos secret/docker)"\"
    echo docker_ee_subscriptions_redhat: \""$(vault kv get -field subscriptions_redhat secret/docker)"\"
    echo docker_ee_subscriptions_oracle: \""$(vault kv get -field subscriptions_oracle secret/docker)"\"
    echo docker_ee_subscriptions_sles: \""$(vault kv get -field subscriptions_sles secret/docker)"\"
    echo docker_ucp_license_path: \"/tmp/license.lic\"
    echo docker_ucp_cert_file: \"/tmp/ucp_cert.pem\"
    echo docker_ucp_ca_file: \"/tmp/ucp_ca.pem\"
    echo docker_ucp_key_file: \"/tmp/ucp_key.pem\"
    echo docker_dtr_cert_file: \"/tmp/dtr_cert.pem\"
    echo docker_dtr_ca_file: \"/tmp/dtr_ca.pem\"
    echo docker_dtr_key_file: \"/tmp/dtr_key.pem\"
} > /tmp/docker_credentials.yml
vault kv get -field license secret/docker > /tmp/license.lic
vault kv get -field ucp_cert secret/docker > /tmp/ucp_cert.pem
vault kv get -field ucp_ca secret/docker > /tmp/ucp_ca.pem
vault kv get -field ucp_key secret/docker > /tmp/ucp_key.pem
vault kv get -field dtr_cert secret/docker > /tmp/dtr_cert.pem
vault kv get -field dtr_ca secret/docker > /tmp/dtr_ca.pem
vault kv get -field dtr_key secret/docker > /tmp/dtr_key.pem
