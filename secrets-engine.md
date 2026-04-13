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