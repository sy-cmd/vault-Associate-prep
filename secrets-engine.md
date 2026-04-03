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
