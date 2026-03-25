# Vault 
+ Vault is a tool that is used to store sensitive data and it is the secret management for mission-critical data whether you deploy systems on-premises, in the cloud, or in a hybrid environment.
### Why should I use Vault
+ vault helps to  harden applications by centralizing secrets management 
 + Manage static secrets
 + Manage certificates
 + Manage identities and authentication
 + Manage 3rd-party secrets
 + Manage sensitive data
 + Support regulatory compliance

### What is a plugin
+ plugins act as building blocks in vault lets us control how data moves through the environment and who can access it:
  + authentication plugins 
  + general secret plugins that generate, store, manage, or transform sensitive information.
  + database secret plugins that manage dynamic credentials that clients use to access database data.


### where does vault store data 
+ integrated - inbuilt( Raft ) which has HA and provides backup/restore capabilities.
+ fileSystems - vault store on the local path which doesn't have HA 
+ in memory - vault stores the data in memory which is mostly used in dev mode.
+ external - which can be AWS,Azure,Google cloud, MySql etc 


## Authentication

### Auth methods 
+ these are components in vault that are responsible to identifying the person or machine who's authenticating  with vault and they have the access to vault according to the policies attached to the token 
+ when the auth method that was created gets deleted all the people who had access via that method it gets deleted as well 

### Enabling the userpass  
```
## Enable the Userpass Auth Method
vault auth enable userpass

### to use a different path 
vault auth enable -path=myuserpass userpass

## Create a User 
vault write auth/userpass/users/<username> \
    password=<password> \
    policies=<policy-name>

### example 
vault write auth/userpass/users/john \
    password=mySecurePass123 \
    policies=default

### example 2 adding TTL
vault write auth/userpass/users/john \
    password=mySecurePass123 \
    policies=default \
    token_ttl=1h \
    token_max_ttl=8h

### Verify the User
# List all users
vault list auth/userpass/users

# Read details of a specific user
vault read auth/userpass/users/john

## Authenticate
vault login -method=userpass username=john
```
## Tokens
+ tokens are the core of aunthntication in vault, tokens can be used directly with auth methods.
+ `vault opeator init` is the only method that can not be disabled and as its the first auth method 
 + The rest of the tokens that are created they all have the same properties 
+ within vault tokens have access to the cluster according to the policies attached to them.

## Token store 
+ auth authentication backed its responsible for creating and storing tokens and can't be disabled. it is the only method that has no login capabilities 

### Token types 
+ there are two types of tokens
  + Batch - these are tokens that carry enough information to be used by vault actions and they don't have the features in service tokens 
  + Service -  these are tokens with many features such as renewal revoking and can create children. we can also track them 

Root tokens 
These are tokens with root capabilities and have the root police. they can do anything in  vault and don't have TTL. we can create root tokens in three ways 
+ via the inistial `vault operator init`
+ by using another root token , a root token with an expiration date can't create a root token that nerver expires 
+ by using `vault operator generate-root`
```
# vault operator geneeate-root

```
