#!/bin/bash
{
    echo client_id       = \""$(vault kv get -field client_id       secret/azure)"\"
    echo client_secret   = \""$(vault kv get -field client_secret   secret/azure)"\"
    echo subscription_id = \""$(vault kv get -field subscription_id secret/azure)"\"
    echo tenant_id       = \""$(vault kv get -field tenant_id       secret/azure)"\"
    echo ssh_private_key_path=\"/tmp/ssh_private_key\"
}     > /tmp/cloud_credentials.auto.tfvars;
vault kv get -field private_key secret/azure > /tmp/ssh_private_key
