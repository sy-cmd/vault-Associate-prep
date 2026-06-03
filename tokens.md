### Token hierarchies and orphan tokens
parent-child
+ When a token holder creates another token that token becomes the child of the initial token , and the child token can also create tokens which can be its children. When the parent token is revoked all of its children are revoked too including the sub children too.
orphan 
+ these are tokens with no parents they are the root of their own token tree, we can create them via  
  + Via write access to the `auth/token/create-orphan` endpoint
  + by using sudo or root access to the `auth/token/create` and setting the `no_parent` parameter to true 
  + By logging in with any other non token method
we can revoke thses tokens from here `auth/token/revoke-orphan` endpoint 

### Token accessors
when a token is created, t token accessor is also created and returned. this accessor is a value that acts as a reference to a token and can perform limited actions:
+ look up tokens properties 
+ look uo a token capabilities on a path 
+ renew the token 
+ revoke the token 
we can list tokens via `auth/token/accessors`

### Token Time-To-Live, periodic tokens, and explicit max TTLs
+ every non root token has TTL associated with it, and when it expires it gets revoked ( non root token have 0 TTL  which means they have no expiration time )
+ we can renew the vault token via `vault token renew`

## creating batch tokens 
```
# Create a token with broader permissions (from root)
# Using "root" policy isn't allowed for batch tokens, but using a policy with specific grants works

# First, check what policies your root token has
vault token lookup | grep policies

# Create a policy that explicitly allows token creation and batch tokens
cat > batch-creator.hcl << EOF
path "auth/token/create" {
  capabilities = ["create", "update", "sudo"]
}

path "auth/token/create-orphan" {
  capabilities = ["create", "update", "sudo"]
}
EOF

vault policy write batch-creator batch-creator.hcl

# Create token with this policy
CREATOR_TOKEN=$(vault token create -policy=batch-creator -ttl=10m -field=token)

# Now create batch token
VAULT_TOKEN=$CREATOR_TOKEN vault token create -type=batch -ttl=5m

```