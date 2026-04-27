# Secrets Engines 

+ they store ,generate and Encrypt data in vault

secrets engines they path based like everything else in vault and we can 
+ enable -- this enables secret at a given path, vault secrets engine is case sensitive which means that when we enable a secret this path `KV` and another one at `kv` these two are considered as two different secrets engines
+ disable - we can disable secrets from the their paths and when we disable a secrets all its connections are revoked and  all the data that was stored in the physical lever is deleted 
+ move -- we can move the engine and once we move the engine all the previous access to it that directs the old path are revoked 
+ tune -- this tunes secrets engines like TTLs

## Database secrets engine
+ The database secrets engine generates credentials for databases based on the configured roles. it works with different databases through plugins 
+ this means that services no longer need hardcode credentials for them to access the databases they can request the credentials from vault.
+ dynamic roles or dynamic secrets these are secrets that are different for each service and they are generated upon request 

### Static roles
+ with static secrets roles these are a `1 to 1` where only it Manages password for a single, existing database user.
+ they are a longer TTL compared to the Dynamic roles 


### Setup
```
### enabling the secrets engine
+ vault secrets enable database

### we configure vault with the credetial for the database 
vault write database/config/my-database \
    plugin_name="..." \
    connection_url="..." \
    allowed_roles="..." \
    username="..." \
    password="..." \

vault write database/config/postgres-demo \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/appdb" \
    username="vault_admin" \
    password="admin123"


vault write database/config/postgres-demo \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://postgres:postgres@10.43.193.89:5432/testdb" \
    username="postgres" \
    password="postgres"

![alt text](image-2.png)



### after configuration we need to rotate the password so that only vault can be the only user who manages it and know the credentials
+ vault write -force database/rotate-root/postgres-demo

```
### Create a Dynamic Role
+ they generate new users try to access the database, and the credentials they are short lived and easy to clean up.
+ we create a `readonly.sql` that vault should execute when creating a new user 
#### readonly.sql
```
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
```
#### creating the dynamic role 
```
vault write database/roles/dynamic-app-role \
    db_name="postgres-demo" \
    creation_statements=@readonl.sql \
    default_ttl="1h" \
    max_ttl="24h"

### when done 

![alt text](image-3.png)
```

### Create a Static Role
+ static roles they manage password rotations for an exiting user and they 1:1 relation 
+ it requires the user to be already existing in PostgreSQL
#### static.sql
to create one manually 
```
CREATE USER legacy_app WITH LOGIN PASSWORD 'oldpassword';
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO legacy_app;
```
creating the static role 
```
vault write database/static-roles/static-app-role \
    db_name="postgres-demo" \
    username="legacy_app" \
    rotation_period="24h"
```
higher version of vault we can provide the intial password 
```
vault write database/static-roles/static-app-role \
    db_name="postgres-demo" \
    username="legacy_app" \
    rotation_period="24h" \
    rotation_statements="ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';" \
    password_wo="oldpassword"
```
+ getting the credentials for static 
  + `vault read database/static-creds/static-app-role`

### Testing and Verification
Dynamic credential 
```
# Request fresh credentials
vault read database/creds/dynamic-app-role

# Connect to PostgreSQL with them
psql -h localhost -U v-root-dynamic-Mop0jmV6qCkFhmuT6ftu-1652122668 -d appdb
```

### Test static credentials
```
# Get current password for the static user
vault read database/static-creds/static-app-role

# Connect with the same username each time
psql -h localhost -U legacy_app -d appdb
# (use the password from Vault)
```

### cleanUp
```
# Revoke all dynamic credentials for a role
vault lease revoke -prefix database/creds/dynamic-app-role

# Delete the roles
vault delete database/roles/dynamic-app-role
vault delete database/static-roles/static-app-role

# Delete the connection
vault delete database/config/postgres-demo

# Disable the secrets engine (if no longer needed)
vault secrets disable database
```

##  keyValue KV 
+ kv secrets engine is a key value store that stores values within the configured physical storage for vault. we can simply store static secrets in kv secrets engine 
### difference between KV1 and KV2 
+ `Versioning` -- kv1 has no version history , updates permanetly overwrite previous keys, kv2 has version history and we can recover delete keys 
+ `DATA` in kv1 data is permanetly deleted while in kv2 data can be recoved and it can only be permanetly deleted when the kv2 is destroyed 
+ it has now metadata tracking while kv2 has metadata tracking 
+ `API` path --- KV1 `secret/key_path` while KV2 `secret/data/<key_path>` , `secret/metadata/<key_path>`
+ `Storage overhead` - kv1 doesn't require a lot of storage has it doesn't store version or metadata like kv2 

### Practical 
```
## we enable the secret at secrets 
vault secrets enable -path=kv2 -version=2 kv

## we can verifly the secret with 
vault secrets list -detailed | grep kv2

## writing a secret to the kv
vault kv put kv2/web-app \
  api-key="abc123xyz" \
  db-password="SecurePass123"

OUTPUT -- it also includes the version of the key 
![alt text](image-4.png)

### to get the secret 
 vault kv get kv2/web-app 

 ### to read a specific version 
 vault kv get -version=1 kv2/web-app

### to read the metadata only 
vault kv metadata get kv2/web-app

### update and versioning this creates version 2 
vault kv put secret/web-app \
  api-key="new-key-456" \
  db-password="SecurePass123"


### Update only one field using patch (KV v2 only)
vault kv patch secret/web-app api-key="patched-key-789"

### delete and recover this deletes the latest version and it becomes inaccessible 
vault kv delete kv2/web-app

### when we try to access it 
![alt text](image-5.png)

### when can confirm from the metadata when the latest version has been deleted 
vault kv metadata get  kv2/web-app 

### Undelete ( recover)
vault kv undelete -versions=3 kv2/web-app

### destroy to permanently destroy the version
vault kv destroy -versions=3 kv2/web-app

```


### Difference between static and dynamic secrets 
+ static secrets these are secrets that don't need changing very often and they don't expire. we store them in secretes engine like `KV`
 + examples of secrets API keys , username and password, 3rd party tokens , encryption keys 
+ dynamic secrets these are secrets that are created on demand and they do expire based on their TTL 
  + with dynamic secrets vault intergrates with a 3rd party that requests for these secrets 
  + examples of dynamic secrets , database keys , cloud provider credentials , and also the transit data engine does not store data but only handles encryption and decryption of data 


## Identity secrets engine
+ its the identity management for vault and it maintains the accounts that are identified by vault. 

### transit secrets engine 
+ the primary use case for the  transit secrets engine is to encrypt and decrypt data , it removed the burden from developers and puts it on vault.
Features of the transit secrets engine:
+ sign and verify data 
+ generates hashes and HMACs of data 
+ Act as a source of random bytes 

### practical 
````
### we need to enable the secrets engine
+ vault secrets enable transit 

if i want to mount it at a different path i use the path parameter 
+ vault secrets enable -path=encryption transit

### we create an encryption key ring named orders 
+ vault write -f transit/keys/orders
````
### Encrypt secrets
#### we need to have a token that has UPDATE cababilities on the path of our transit engine
> vault policy write app-orders -<<EOF
path "transit/encrypt/orders" {
   capabilities = [ "update" ]
}
path "transit/decrypt/orders" {
   capabilities = [ "update" ]
}
EOF

#### we create a token with the policy 
> vault token create -policy=app-orders

+ we store the token in a variable  
> export APP_ORDER_TOKEN=$(vault token create \
    -policy=app-orders \
    -format=json | jq -r '.auth | .client_token')


we encrypt data from the shell to base64 
> VAULT_TOKEN=$APP_ORDER_TOKEN vault write transit/encrypt/orders \
    plaintext=$(base64 <<< "4111 1111 1111 1111")

we save the encypted data in a variable 
> export CIPHERTEXT=$(VAULT_TOKEN=$APP_ORDER_TOKEN vault write transit/encrypt/orders \
    plaintext=$(base64 <<< "4111 1111 1111 1111")\
    -format=json | jq -r '.data | .ciphertext')

### Decrypt ciphertext
+ any client holding a token with right permissions can decrypt encrypted data 

#### decrpting the text above 
> VAULT_TOKEN=$APP_ORDER_TOKEN vault write \
    transit/decrypt/orders ciphertext=$CIPHERTEXT

#### the resulting data is base64 we need to decode it 
base64 --decode <<< "NDExMSAxMTExIDExMTEgMTExMQo="

### Rotate the encryption key
+ To rotate encrption keys we need to use this endpoint `transit/keys/<key_ring_name>/rotate`
 + here we are using `orders`

```
### we create a rotate which will be called for rotation 
vault write -f transit/keys/orders/rotate

### we encrypt data with a new key 
vault write transit/encrypt/orders plaintext=$(base64 <<< "4111 1111 1111 1111")

### we can rewrap the key with the latest keyring 
vault write transit/rewrap/orders \
    ciphertext=$CIPHERTEXT

```
### Automatic key rotation 
+ we can also automate the key rotations at a time interval 

#### we read orders key information 
+ vault read transit/keys/orders 

+ `auto_rotate_period ` parameter configures how the auto rotate should rotate the keys 

### configure to rotate every 24h 
> vault write transit/keys/orders/config auto_rotate_period=24h




mentor model 
`vault path-help transit`