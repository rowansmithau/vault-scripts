#!/bin/bash

# original source: https://www.reddit.com/r/devops/comments/dondb9/hashicorp_vault_deleting_users_and_revoking_all/

DELETE_USER=bob

for acc in $(vault list -format=json auth/token/accessors | jq -r '.[]'); do
  token_path=$(vault token lookup -format=json -accessor $acc | jq -r '.data.path')
  echo $token_path
  if [[ "$token_path" == "auth/userpass/login/$DELETE_USER" ]]; then
    vault token revoke -accessor $acc
  fi
done
