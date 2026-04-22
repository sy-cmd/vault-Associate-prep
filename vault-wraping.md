## Response wrapping 
+ Response wrapping is the way of protecting data that is being transferred  from one environment to another.
+ features of the wrapping  
  + it provides cover by not exposing the actual data when its in transit only the referenced data 
  + it provides protection to the secrets thats being transferred by allowing the intended person to only unseal the token 
  + it limits the exposer of the secret by have a TTL, and when they person we sent the data doesn't unwrap the token in time it expires 

### Response-Wrapping token operations
+ ``lookup` - we can lookup the token like checking the date and time it was created 
+ `unwrap` - we can unwrap the token to check the secrets inside 
+  `rewrap` - we rewrap the token to give it a a longer TTL 
+  `wrap` - used to wrap data that is that will be used in transit.
+  

### practical 
```
### wrapping a a secret
+ vault kv get -wrap-ttl=120s secret/dev

then we get the response token and use that in transit 

### unwrapping 
+ VAULT_TOKEN="hvs.CAESIK9v...Ft7pQ" vault unwrap
```