## Using the api method to authenticate in vault 
we need to have the following:
+ vault binary -- to configure the server.
+ json -- it gives us the data that is easy to read 
+ curl -- we use it to send data to the server 

### steps 
1. we setup the environment 
+ ` vault server -dev ` or `vault server -dev -dev-root-token-id root -dev-tls` 

2. we configure our terminal with the credentials for vault 
+ `export VAULT_TOKEN=root`
+  `export VAULT_ADDR='https://127.0.0.1:8200'`
+  `export VAULT_CACERT='/tmp/vault-tls1056313322/vault-ca.pem'`
+ Set an environment variable CURL_CA_BUNDLE, CURL uses that locate a CA cert.
  + `export CURL_CA_BUNDLE=$VAULT_CACERT`

3. Using the HTTP API to check the server status 
+ `curl -s $VAULT_ADDR/v1/sys/seal-status | jq`
4. we can also tell vault to give us the method we can use if we want to check the status of the saver using curl 
+ `vault status -output-curl-string` -- this gives us the command we can use to use curl when checking for the status 

### Headers and paths 
HTTP headers let the client and server pass information via 
HTTP request or response.
+ we set our token with the **X-Vault-Token** header to pass the token 
+ we need the address for the server and the path we shall be reading 
```
curl \
  --header "X-Vault-Token: hvs.YOUR_TOKEN" \
  --request GET \
  https://127.0.0.1:8200/v1/sys/health


```
+ we can also use 
 + -X --- Request Method ( GET,POST,DELETE ) 
 + -H --- adds the HTTP header to the request 

```
curl \
-H "X-Vault-Token: VAULT_TOKEN" \
-X GET \
https://127.0.0.1:8200/v1/sys/health

```

```

curl --cacert '/tmp/vault-tls1056313322/vault-ca.pem' -H "X-Vault-Request: true" -H "X-Vault-Token: $(vault print token)" https://127.0.0.1:8200/v1/sys/seal-status

```
+ syntax to using 
  + curl -s "TOKEN

5. if we wnat to enable an authentication method 
+ CLI-- ` vault auth enable <auth_method_type> `

+ via HTTP API 
``` 
curl \
-H "X-Vault-Token: VAULT_TOKEN \
-X POST \
-d '{"type": "userpass"}' \
  $VAULT_ADDR/v1/sys/auth/userpass
```
+ to list the vault auth methods via HTTP API 
```
curl \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  $VAULT_ADDR/v1/sys/auth  | jq ".data"

```

+ To create a userpass 
```
curl \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  -X POST \
  -d '{"password":"Imprint Bacteria Marathon Aflutter","token_policies":"developer-vault-policy"}' \
  $VAULT_ADDR/v1/auth/userpass/users/danielle-vault-user
```
+ we can create policies via this endpoint `v1/sys/policies/acl` 
```
curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X PUT \
    -d '{"policy":"path \"dev-secrets/data/creds\" {\n  capabilities = [\"create\", \"update\"]\n}\n\npath \"dev-secrets/data/creds\" {\n  capabilities = [\"read\"]\n}\n"}' \
    $VAULT_ADDR/v1/sys/policies/acl/developer-vault-policy

```
+ to list the policies we use this endpoint v1/sys/policy
```
curl -s -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/policy | jq ".data.policies"
```

## Enable and configure a secrets engine
+ we can check the mounted secrets with `v1/sys.mounts`
```
curl -s \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  $VAULT_ADDR/v1/sys/mounts | jq ".data"
```
+ we create a secrets engine at dev-secrets with 
```
curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X POST \
    -d '{ "type":"kv-v2" }' \
    $VAULT_ADDR/v1/sys/mounts/dev-secrets
```
## Authenticate and create secrets 
+ since we have created the polices and secrets engine we can the token and the output returns a login toekn that we can use 
``` 
curl -s \
  -X POST \
  -d '{ "password": "Imprint Bacteria Marathon Aflutter" }' \
  $VAULT_ADDR/v1/auth/userpass/login/danielle-vault-user | jq ".auth.client_token"
```
+ we `export DANIELLE_DEV_TOKEN=hvs....`
+ we create a secret named creds with key password
```
curl -s \
  -H "X-Vault-Token: $DANIELLE_DEV_TOKEN" \
  -X PUT \
  -d '{ "data": {"password": "Driven Siberian Pantyhose Equinox"} }' \
  $VAULT_ADDR/v1/dev-secrets/data/creds | jq ".data"
```