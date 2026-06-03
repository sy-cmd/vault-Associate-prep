path "auth/token/create" {
  capabilities = ["create", "update", "sudo"]
}

path "auth/token/*" {
  capabilities = ["read", "list", "delete"]
}