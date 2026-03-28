# Policies
+ everything in vault is path based, policies provide a way to grant or forbid access to certain paths 

## Policy syntax
+ policies are written in hcl syntax , and they define which path to grant or denial access 
this policy give access to secret path with read only 
````
path "secret/wee" {
    capabilties = ["read"]

}
````
more examples 
```
# This section grants all access on "secret/*". further restrictions can be
# applied to this broad policy, as shown below.
path "secret/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

# Even though we allowed secret/*, this line explicitly denies
# secret/super-secret. this takes precedence.
path "secret/super-secret" {
  capabilities = ["deny"]
}

# Policies can also specify allowed, disallowed, and required parameters. here
# the key "secret/restricted" can only contain "foo" (any value) and "bar" (one
# of "zip" or "zap").
path "secret/restricted" {
  capabilities = ["create"]
  allowed_parameters = {
    "foo" = []
    "bar" = ["zip", "zap"]
  }
}
```

Polices use a matching test to check the capabilities of a token and the policy its attached too. 
+ `*` means everything matching that path 
```
# Permit reading only "secret/foo". an attached token cannot read "secret/food"
# or "secret/foo/bar".
path "secret/foo" {
  capabilities = ["read"]
}

# Permit reading everything under "secret/bar". an attached token could read
# "secret/bar/zip", "secret/bar/zip/zap", but not "secret/bars/zip".
path "secret/bar/*" {
  capabilities = ["read"]
}

# Permit reading everything prefixed with "zip-". an attached token could read
# "secret/zip-zap" or "secret/zip-zap/zong", but not "secret/zip/zap
path "secret/zip-*" {
  capabilities = ["read"]
}
```
+ `+` this means the segment or tags between the paths 
```
# Permit reading the "teamb" path under any top-level path under secret/
path "secret/+/teamb" {
  capabilities = ["read"]
}
# anything with :
secret/production/teamb
secret/dev/teamb

won't read 
secret/demo/dev/teamb

# Permit reading secret/foo/bar/teamb, secret/bar/foo/teamb, etc.
path "secret/+/+/teamb" {
  capabilities = ["read"]
}

anything with 3 segments 
secret/demo/dev/teamb
```