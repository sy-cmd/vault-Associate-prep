# Identity 
The main purpose of identity is for vault to be able to recognized its clients. and it has `Identity secrets engine`. 

## Entities and aliases
+ `Entity` in vault is a representation of a client that authenticates in vault ( human or machine  ). they are stored in `Identity secrets engine` by default. the identity secrets engine can't be moved or disabled its mounted by default.

+ Alias is a link between an Entity and a specific authentication method account. one entity can have multiple alias but can not have multiple alias for the same auth method. 

+ when a clients authenticates via any credential backend vault creates an entity and attaches an alias if it doesn't exist. ( except the token backend )

## Entity policies
+  entities can be assigned polices which adds permission to the polices associated with the token backend. 
+  since the polices they are evaluated when they are being executed. 
![alt text](image-8.png)

## Implicit entities
Operators can create entities for all the users of an auth mount beforehand and assign policies to them, so that when users login, the desired capabilities to the tokens via entities are already assigned. But if that's not done, upon a successful user login from any of the authentication backends, Vault will create a new entity and assign an alias against the login that was successful.

Note that the tokens created using the token authentication backend will not normally have any associated identity information. An existing or new implicit entity can be assigned by using the entity_alias parameter, when creating a token using a token role with a configured list of allowed_entity_aliases.

### Identity auditing
+ if a token that was used to login has an entity vault save it log and trails of actions which where performed by the user 

### Identity groups
vault identity supports group management. Entities in a group have the polices of the group. groups helps us to sort multi users that must have the same polices, we just have them in  a group which grants them the required polices 

### External vs internal groups
+ groups that are created in the identity store they are called internal groups.
+ external groups are created outside of the identity store

## Implement identity entities and groups

### Create an Entity with Alias
+ BOb have two credentials in vault that are not connected to each other and we would like to create an entity that has two alias that represents this data. 
### policies required 
```
## base policy 
vault policy write base -<<EOF
path "secret/data/training_*" {
   capabilities = ["create", "read"]
}
EOF
```

```
## test 
vault policy write test -<<EOF
path "secret/data/test" {
   capabilities = [ "create", "read", "update", "delete" ]
}
EOF
```
```
## team-qa
vault policy write team-qa -<<EOF
path "secret/data/team-qa" {
   capabilities = [ "create", "read", "update", "delete" ]
}
EOF
```
### we enable the userpass 
+ `vault auth enable -path="userpass-test" userpass`
+ we create a user bob and password training and give it policy test 
  + `vault write auth/userpass-test/users/bob password="training" policies="test"`
+ we enable userpass at userpass-qa `vault auth enable -path="userpass-qa" userpass`
 + we create the user and password
 + `vault write auth/userpass-qa/users/bsmith password="training" policies="team-qa"`
+ we use save the accessors of each auth we created 
  + `vault auth list -format=json | jq -r '.["userpass-test/"].accessor' > accessor_test.txt`
  + `vault auth list -format=json | jq -r '.["userpass-qa/"].accessor' > accessor_qa.txt`
+ we create an entity for bob-smith 
> vault write -format=json identity/entity name="bob-smith" policies="base" \
     metadata=organization="ACME Inc." \
     metadata=team="QA" \
     | jq -r ".data.id" > entity_id.txt
+ we add bob to the bob-smith entity 
> vault write identity/entity-alias name="bob" \
     canonical_id=$(cat entity_id.txt) \
     mount_accessor=$(cat accessor_test.txt) \
     custom_metadata=account="Tester Account"
+ we add bsmith to he bob-smith entity 
> vault write identity/entity-alias name="bsmith" \
     canonical_id=$(cat entity_id.txt) \
     mount_accessor=$(cat accessor_qa.txt) \
     custom_metadata=account="QA Eng Account"
+ we can review the entity details 
> vault read -format=json identity/entity/id/$(cat entity_id.txt) | jq -r ".data"