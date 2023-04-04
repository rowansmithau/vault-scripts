#!/opt/homebrew/bin/zsh

# Generates 520 Vault entities, then assigns them to a group
# Used to test group exhaustion theory

GROUPNAME=treehouse
for i in {1..23002}
do
	VAULT_NAMESPACE=sftest2 vault write -field=id identity/entity name=conor_clone_no_${i} policies=test
done

ENTITIES=$(VAULT_NAMESPACE=sftest2 vault list identity/entity/id | sed 1,2d | tr '\n' ',' | sed 's/.$//')

VAULT_NAMESPACE=sftest2 vault write identity/group name=$GROUPNAME member_entity_ids="$ENTITIES"

COUNT=$(VAULT_NAMESPACE=sftest2 vault read identity/group/name/$GROUPNAME -format=json | jq '.data.member_entity_ids | length')


echo "------------------------------------"
echo "Member count for $GROUPNAME is $COUNT"
