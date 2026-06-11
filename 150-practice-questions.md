# HashiCorp Certified: Vault Associate (003) — 150 Practice Questions

> New question set to supplement `200-with-answers.md`. Covers all 9 exam domains with extra focus on:
> Vault UI operations, Vault Agent, HCP Vault, human vs system auth, and root token lifecycle.
>
> Sources: Official HashiCorp sample questions, VMExam free samples, exam objectives review.

---

## Domain Distribution

| Domain | Weight | Questions |
|--------|--------|-----------|
| 1. Authentication Methods | 14% | 21 |
| 2. Vault Policies | 12% | 18 |
| 3. Vault Tokens | 12% | 18 |
| 4. Vault Leases | 8% | 12 |
| 5. Secrets Engines | 16% | 24 |
| 6. Encryption as a Service | 6% | 9 |
| 7. Architecture Fundamentals | 10% | 15 |
| 8. Deployment Architecture | 12% | 18 |
| 9. Access Management Architecture | 10% | 15 |

---

## Domain 1: Authentication Methods (Questions 1–21)

### True/False

**1.** True or False: OIDC is classified as a human-oriented authentication method.

**2.** True or False: The token auth method can be disabled by an operator.

**3.** True or False: A single Vault entity can have aliases from multiple different auth methods.

**4.** True or False: AppRole is classified as a machine/system authentication method.

**5.** True or False: When an auth method is disabled, all tokens issued by that method are immediately revoked.

---

### Multiple Choice

**6.** What is the primary difference between human and machine authentication methods?

- A) Human methods use shorter TTLs
- B) Human methods involve interactive login flows; machine methods use pre-provisioned credentials
- C) Machine methods are more secure by default
- D) Human methods always require MFA

**7.** In the Vault UI, where do you navigate to enable a new authentication method?

- A) Secrets → Enable new engine
- B) Access → Auth Methods → Enable new method
- C) Policies → Auth → Add
- D) Settings → Security → Auth

**8.** Which auth method is designed specifically for workloads running on AWS EC2 instances?

- A) AppRole
- B) LDAP
- C) AWS
- D) TLS Certificate

**9.** What two pieces of information are required to log in with AppRole?

- A) username + password
- B) role_id + secret_id
- C) entity_id + alias_name
- D) accessor + client_token

**10.** Which command correctly reads the AppRole `role_id` for a role named `webapp`?

- A) `vault read auth/approle/role/webapp/role-id`
- B) `vault get auth/approle/webapp/id`
- C) `vault auth read approle/webapp`
- D) `vault list auth/approle/role/webapp`

**11.** What does an external group in Vault Identity represent?

- A) A group of Vault policies
- B) A group whose membership is managed by an external identity provider (e.g., LDAP group)
- C) A group of storage backends
- D) A group of secrets engines

**12.** Which command lists all currently enabled authentication methods?

- A) `vault list auth/`
- B) `vault auth methods`
- C) `vault auth list`
- D) `vault read sys/auth`

**13.** What is the purpose of `bound_service_account_names` in the Kubernetes auth method?

- A) To set the TTL for Kubernetes-issued tokens
- B) To restrict which Kubernetes service accounts are allowed to authenticate
- C) To name the Vault role
- D) To bind the Vault policy to a namespace

**14.** How do you authenticate to Vault using the HTTP API with token auth?

- A) Pass the token as a query parameter: `?token=<value>`
- B) Include the `X-Vault-Token` header in the request
- C) Use HTTP Basic Auth with token as password
- D) Set the `Authorization: Bearer` header

**15.** Which Vault CLI command authenticates using the `userpass` method with the username `alice`?

- A) `vault auth userpass -user=alice`
- B) `vault login -method=userpass username=alice`
- C) `vault authenticate userpass alice`
- D) `vault write auth/token/login username=alice`

---

### Multiple Answer (Choose 2)

**16.** Which of the following are human-oriented authentication methods? (Choose 2)

- A) AppRole
- B) OIDC
- C) Kubernetes
- D) GitHub
- E) AWS IAM

**17.** Which of the following are machine/system authentication methods? (Choose 2)

- A) LDAP
- B) Userpass
- C) Kubernetes
- D) AppRole
- E) OIDC

**18.** Which statements about entity aliases are correct? (Choose 2)

- A) An alias links an external auth identity to a Vault entity
- B) Aliases are used to store encrypted secrets
- C) A single entity can have multiple aliases from different auth methods
- D) Aliases replace the need for Vault policies
- E) Aliases are only valid for machine auth methods

---

### Scenario-Based

**19.** Your team authenticates to their corporate systems via LDAP. They need the same identity used to access Vault secrets. Which auth method should you configure?

- A) AppRole
- B) GitHub
- C) LDAP
- D) AWS

**20.** In the Vault UI, an operator wants to configure an AppRole auth method. After navigating to **Access → Auth Methods → Enable new method**, which option do they select?

- A) Token
- B) AppRole
- C) Userpass
- D) OIDC

**21.** A developer needs to verify which accessor is associated with the `approle/` auth mount. Which command returns this information?

- A) `vault auth list -detailed`
- B) `vault read auth/approle/`
- C) `vault auth info approle`
- D) `vault list sys/auth/approle`

---

<details>
<summary>Domain 1 Answers</summary>

1. True
2. False (token auth method cannot be disabled)
3. True
4. True
5. True
6. B
7. B
8. C
9. B
10. A
11. B
12. C
13. B
14. B
15. B
16. B, D
17. C, D
18. A, C
19. C
20. B
21. A

</details>

---

## Domain 2: Vault Policies (Questions 22–39)

### True/False

**22.** True or False: The `patch` capability allows partial updates to a secret without overwriting the entire value.

**23.** True or False: The `root` policy can be edited to restrict what root tokens can access.

**24.** True or False: If a token has both `read` and `deny` capabilities on the same path, `deny` always wins.

**25.** True or False: Policy names in Vault are case-sensitive.

---

### Multiple Choice

**26.** In the Vault UI, where do you navigate to create or edit a policy?

- A) Secrets → Policies
- B) Access → Policies
- C) Settings → ACL
- D) Tools → Policy Editor

**27.** What does the `+` wildcard represent in the path `kv/data/+/config`?

- A) Any number of path segments
- B) Exactly one path segment
- C) Only alphanumeric characters
- D) Any path ending in `/config`

**28.** Which capability is required to list the keys at a path without reading their values?

- A) `read`
- B) `create`
- C) `list`
- D) `sudo`

**29.** What command deletes the policy named `old-policy` via the CLI?

- A) `vault policy remove old-policy`
- B) `vault delete sys/policy/old-policy`
- C) `vault policy delete old-policy`
- D) `vault policy write old-policy -`

**30.** Which path requires the `sudo` capability to access?

- A) `kv/data/app/secret`
- B) `sys/seal`
- C) `auth/userpass/login`
- D) `identity/entity`

**31.** What is identity templating in Vault policies used for?

- A) Encrypting policy definitions
- B) Allowing policies to dynamically reference the authenticated entity's metadata
- C) Generating policy names automatically
- D) Creating policies from Terraform templates

**32.** Which command shows what capabilities a given token has on a specific path?

- A) `vault token verify <token> <path>`
- B) `vault token capabilities <token> <path>`
- C) `vault policy check <path>`
- D) `vault auth check <token> <path>`

**33.** Which path controls the ability to enable or disable auth methods?

- A) `auth/*`
- B) `sys/auth/*`
- C) `identity/auth/*`
- D) `sys/mounts/auth/*`

---

### Multiple Answer (Choose 2)

**34.** Which of the following are valid Vault policy capabilities? (Choose 2)

- A) `patch`
- B) `modify`
- C) `deny`
- D) `execute`
- E) `sudo`

**35.** A policy grants `read` on `secret/data/*`. A second policy grants `deny` on `secret/data/admin`. What is true? (Choose 2)

- A) The token can read `secret/data/app`
- B) The token can read `secret/data/admin` because `read` was granted first
- C) The token cannot read `secret/data/admin` because `deny` takes precedence
- D) `deny` only applies if no other policy exists
- E) `deny` capability overrides all other capabilities on that path

---

### Scenario-Based

**36.** An application must be able to read and list secrets under `kv/data/payments/*` but must never be able to delete them. Which capabilities should the policy include?

- A) `["read", "list", "delete"]`
- B) `["read", "list"]`
- C) `["read", "create", "update"]`
- D) `["list", "sudo"]`

**37.** You want to write a policy that lets each user access only their own secrets using identity templating. Which path syntax is correct?

- A) `path "kv/data/users/{{identity.entity.name}}/*"`
- B) `path "kv/data/users/${identity.name}/*"`
- C) `path "kv/data/users/<entity_name>/*"`
- D) `path "kv/data/users/+/*"`

**38.** A security team wants to allow a service to renew its own token but not create new child tokens. Which path and capability combination achieves this?

- A) `path "auth/token/renew-self" { capabilities = ["update"] }`
- B) `path "auth/token/create" { capabilities = ["create"] }`
- C) `path "auth/token/*" { capabilities = ["sudo"] }`
- D) `path "sys/token/renew" { capabilities = ["read"] }`

**39.** In the Vault UI, a junior admin says they cannot see the "Edit" button on a policy. What is the most likely reason?

- A) The UI does not support policy editing
- B) The admin's token lacks `update` capability on `sys/policies/acl/*`
- C) The policy is locked by a root token
- D) Policies can only be edited via CLI

---

<details>
<summary>Domain 2 Answers</summary>

22. True
23. False (the root policy cannot be modified or deleted)
24. True
25. False (policy names are case-insensitive)
26. B
27. B
28. C
29. C
30. B
31. B
32. B
33. B
34. A, C (patch, deny — also sudo and others are valid, but from these options)
35. A, C, E (A: can read other paths; C and E: deny takes precedence on admin path)
36. B
37. A
38. A
39. B

</details>

---

## Domain 3: Vault Tokens (Questions 40–57)

### True/False

**40.** True or False: A root token is automatically created during Vault initialization.

**41.** True or False: It is best practice to keep the root token active permanently for emergency administrative access.

**42.** True or False: Batch tokens are stored in Vault's persistent storage backend.

**43.** True or False: Token accessors can be used to revoke a token without knowing the token's actual value.

**44.** True or False: Service tokens created by a parent token are automatically revoked when the parent is revoked.

---

### Multiple Choice

**45.** What is the recommended lifecycle for a root token after initial Vault setup?

- A) Keep it stored securely in a vault (physical) for emergencies
- B) Use it as the primary admin token for daily operations
- C) Revoke it immediately after completing initial configuration; regenerate only when needed
- D) Rotate it weekly using `vault token renew`

**46.** Which command creates a new orphan token with a 24-hour TTL?

- A) `vault token create -ttl=24h -type=service`
- B) `vault token create -orphan -ttl=24h`
- C) `vault token create -no-parent -ttl=24h`
- D) `vault token create -standalone -ttl=24h`

**47.** Which token type is NOT stored in Vault's storage backend and is best suited for high-throughput workloads?

- A) Service token
- B) Periodic token
- C) Batch token
- D) Orphan token

**48.** How do you regenerate a root token when the original has been lost or revoked?

- A) `vault token create -root`
- B) Use `vault operator generate-root` with a quorum of unseal key holders
- C) `vault write sys/root-token`
- D) Reinitialize Vault with `vault operator init`

**49.** What does `vault token lookup -accessor <accessor_id>` return?

- A) The actual token value
- B) The token's metadata (policies, TTL, creation time) without exposing the token value
- C) A new token issued for that accessor
- D) The entity associated with the accessor

**50.** What flag makes a token periodic (renewable indefinitely as long as renewed within the TTL)?

- A) `-renewable=true`
- B) `-period=<duration>`
- C) `-infinite-ttl`
- D) `-max-ttl=0`

**51.** Which token type prefix is used for service tokens in newer Vault versions?

- A) `s.`
- B) `b.`
- C) `hvs.`
- D) `root.`

**52.** What happens when a token with `num_uses=1` is used for the second time?

- A) The token is automatically renewed
- B) The request fails and the token is revoked
- C) The token enters a read-only state
- D) A child token is created automatically

---

### Multiple Answer (Choose 2)

**53.** Which statements correctly describe batch tokens? (Choose 2)

- A) They are stored in Vault's storage backend
- B) They are not persisted — their data is encoded in the token itself
- C) They can be renewed indefinitely
- D) They cannot be renewed
- E) They are ideal for long-lived administrative sessions

**54.** What are valid use cases for token accessors? (Choose 2)

- A) Revoking a token without knowing its value
- B) Authenticating to Vault in place of a token
- C) Looking up token metadata for auditing purposes
- D) Encrypting secrets with the token's key
- E) Creating child tokens from a parent accessor

---

### Scenario-Based

**55.** A monitoring service needs a token that can never expire as long as it is renewed on time, but should have no maximum TTL. Which token type should you create?

- A) Batch token with `-ttl=0`
- B) Service token with `-period=<duration>`
- C) Orphan token with `-max-ttl=never`
- D) Root token

**56.** During a security audit, you need to list all active tokens without exposing their values. Which feature enables this?

- A) `vault token list`
- B) Token accessors via `vault list auth/token/accessors`
- C) `vault audit read tokens`
- D) `vault operator dump-tokens`

**57.** After revoking an auth method, what additional cleanup step ensures no orphaned dynamic credentials remain?

- A) Run `vault operator gc`
- B) Use `vault lease revoke -prefix <auth_path>/` to revoke all associated leases
- C) Manually delete entries in the storage backend
- D) Restart the Vault server

---

<details>
<summary>Domain 3 Answers</summary>

40. True
41. False (root tokens should be revoked after initial setup)
42. False (batch tokens are not stored in the backend)
43. True
44. True
45. C
46. B
47. C
48. B
49. B
50. B
51. C
52. B
53. B, D
54. A, C
55. B
56. B
57. B

</details>

---

## Domain 4: Vault Leases (Questions 58–69)

### True/False

**58.** True or False: KV v2 secrets have leases that must be renewed to keep the secret accessible.

**59.** True or False: Revoking a lease for a database credential causes Vault to drop that user from the database.

**60.** True or False: A lease can be renewed past its `max_ttl` if renewed before expiry.

---

### Multiple Choice

**61.** Which command renews an existing lease by its lease ID?

- A) `vault lease extend <lease_id>`
- B) `vault lease renew <lease_id>`
- C) `vault renew <lease_id>`
- D) `vault write sys/leases/renew lease_id=<lease_id>`

**62.** What does `vault lease revoke -prefix database/creds/readonly/` do?

- A) Revokes only the most recent lease at that path
- B) Revokes all leases under the specified prefix path
- C) Deletes the `readonly` database role
- D) Disables the database secrets engine

**63.** Which secrets engine generates leases for its credentials?

- A) KV v1
- B) KV v2
- C) Database secrets engine
- D) Cubbyhole

**64.** What is the `lease_id` used for?

- A) Identifying which Vault node issued the secret
- B) Uniquely identifying a secret lease so it can be renewed or revoked
- C) Encrypting the secret value in transit
- D) Mapping the secret to a specific entity

**65.** How do you list all active leases under the path `aws/creds/`?

- A) `vault list sys/leases/lookup/aws/creds/`
- B) `vault lease list aws/creds/`
- C) `vault read sys/leases/aws/`
- D) `vault secrets list aws/creds/`

**66.** What happens when a dynamic secret's lease expires and is not renewed?

- A) The secret is archived and can be recovered
- B) The credential is revoked and the associated database user is dropped
- C) The lease is automatically extended by the secrets engine
- D) The token that requested the secret is also revoked

---

### Multiple Answer (Choose 2)

**67.** Which fields are typically included in a Vault lease response? (Choose 2)

- A) `lease_id`
- B) `entity_id`
- C) `lease_duration`
- D) `accessor`
- E) `storage_path`

---

### Scenario-Based

**68.** An application holds a database credential that is about to expire. The app calls `vault lease renew`. The lease has already hit its `max_ttl`. What is the result?

- A) The lease is extended by the default TTL
- B) The renewal fails; the credential is revoked and a new one must be requested
- C) The `max_ttl` is automatically increased
- D) The lease is converted to a static secret

**69.** Your team wants to revoke all AWS credentials issued today during a security incident. Which approach is most efficient?

- A) Manually call `vault lease revoke` for each lease ID
- B) Use `vault lease revoke -prefix aws/creds/` to revoke all credentials at once
- C) Disable and re-enable the AWS secrets engine
- D) Rotate the root AWS credentials only

---

<details>
<summary>Domain 4 Answers</summary>

58. False (KV secrets are static and do not have leases)
59. True
60. False (leases cannot be renewed past max_ttl)
61. B
62. B
63. C
64. B
65. A
66. B
67. A, C
68. B
69. B

</details>

---

## Domain 5: Secrets Engines (Questions 70–93)

### True/False

**70.** True or False: KV v2 supports check-and-set (CAS) to prevent unintended secret overwrites.

**71.** True or False: The cubbyhole secrets engine is shared across all tokens in Vault.

**72.** True or False: You can enable the same type of secrets engine at multiple different paths simultaneously.

**73.** True or False: A soft-deleted KV v2 secret version can be recovered using `vault kv undelete`.

**74.** True or False: Response wrapping creates a multi-use token that contains the wrapped secret.

---

### Multiple Choice

**75.** In the Vault UI, which menu is used to enable a new secrets engine?

- A) Access → Secrets
- B) Secrets → Enable new engine
- C) Settings → Mounts
- D) Tools → Engines

**76.** Which API path is used to read a KV v2 secret at path `secret/data/myapp/config`?

- A) `GET /v1/secret/myapp/config`
- B) `GET /v1/secret/data/myapp/config`
- C) `GET /v1/kv/v2/myapp/config`
- D) `GET /v1/secret/metadata/myapp/config`

**77.** What is the difference between `vault kv delete` and `vault kv destroy` in KV v2?

- A) `delete` is permanent; `destroy` is recoverable
- B) `delete` soft-deletes (recoverable); `destroy` permanently removes the version data
- C) They are identical operations
- D) `destroy` only removes metadata; `delete` removes data

**78.** Which command enables a KV version 2 secrets engine at the path `myapp/`?

- A) `vault secrets enable -path=myapp kv`
- B) `vault secrets enable -path=myapp -version=2 kv`
- C) `vault kv enable -path=myapp`
- D) `vault enable secrets -type=kv2 myapp/`

**79.** What does `vault kv rollback -version=2 secret/myapp` do?

- A) Restores the Vault cluster to a previous snapshot
- B) Copies version 2 of the secret as a new current version
- C) Permanently deletes versions newer than version 2
- D) Reverts the secrets engine configuration

**80.** How many versions does KV v2 retain by default?

- A) 1
- B) 5
- C) 10
- D) Unlimited

**81.** Which secrets engine would you use to issue short-lived X.509 certificates?

- A) Transit
- B) Database
- C) PKI
- D) KV v2

**82.** What command lists all currently enabled secrets engines?

- A) `vault secrets get`
- B) `vault read sys/mounts`
- C) `vault secrets list`
- D) `vault list sys/secret`

**83.** What does the `cas` parameter enforce when writing to KV v2?

- A) It encrypts the secret value using the transit engine
- B) It requires the caller to provide the current version number to prevent accidental overwrites
- C) It triggers automatic key rotation
- D) It sets the TTL for the secret

**84.** Which path is used to read KV v2 secret metadata (not the data itself)?

- A) `secret/data/<path>`
- B) `secret/info/<path>`
- C) `secret/metadata/<path>`
- D) `secret/config/<path>`

---

### Multiple Answer (Choose 2)

**85.** What are advantages of dynamic secrets over static secrets? (Choose 2)

- A) They are generated once and stored permanently
- B) They are unique per request, reducing blast radius if compromised
- C) They expire automatically, limiting credential exposure time
- D) They require no secrets engine configuration
- E) They never need to be rotated

**86.** Which statements about response wrapping are correct? (Choose 2)

- A) The wrapping token can be used multiple times
- B) Only a reference (wrapping token) is transmitted — not the actual secret
- C) The wrapping token has a configurable TTL after which it expires
- D) Response wrapping requires the Transit secrets engine
- E) Wrapping tokens are stored in the cubbyhole permanently

---

### Scenario-Based

**87.** An operations team needs to pass an AppRole `secret_id` to an application securely so that even the pipeline operator cannot see the actual value. Which feature should they use?

- A) KV v2 versioning
- B) Response wrapping
- C) Transit encryption
- D) Entity aliases

**88.** In the Vault UI, a developer wants to read a secret at `kv/data/app/db-password`. Where do they navigate?

- A) Access → Entities → kv → app
- B) Secrets → kv → app → db-password
- C) Tools → Lookup → kv/data/app
- D) Settings → Secrets → kv

**89.** A team accidentally overwrote a KV v2 secret. They need to recover the previous version. Which command do they run?

- A) `vault kv restore secret/app`
- B) `vault kv rollback -version=<previous_version> secret/app`
- C) `vault kv revert secret/app`
- D) `vault kv undo secret/app`

**90.** Your organization uses Vault open source and has two teams that must not share the same KV secrets engine. Without Enterprise namespaces, what is the correct approach?

- A) Create two Vault clusters
- B) Enable a separate KV engine at a different path for each team (e.g., `teamA/` and `teamB/`)
- C) Use entity aliases to separate access
- D) Enable KV v1 for one team and KV v2 for the other at the same path

**91.** A developer queries `vault kv get secret/myapp` and sees `deletion_time` is set. What does this indicate?

- A) The secret engine is being disabled
- B) The current version has been soft-deleted
- C) The secret has been permanently destroyed
- D) The lease for the secret has expired

**92.** Which secrets engine generates time-limited credentials for a PostgreSQL database?

- A) KV v2
- B) Transit
- C) Database
- D) Cubbyhole

**93.** An app needs to enable the database secrets engine via the REST API. Which API call is correct?

- A) `POST /v1/sys/enable/database`
- B) `POST /v1/sys/mounts/database` with `{"type": "database"}`
- C) `PUT /v1/secrets/database/enable`
- D) `POST /v1/database/init`

---

<details>
<summary>Domain 5 Answers</summary>

70. True
71. False (cubbyhole is private per token)
72. True
73. True
74. False (wrapping tokens are single-use)
75. B
76. B
77. B
78. B
79. B
80. C
81. C
82. C
83. B
84. C
85. B, C
86. B, C
87. B
88. B
89. B
90. B
91. B
92. C
93. B

</details>

---

## Domain 6: Encryption as a Service (Questions 94–102)

### True/False

**94.** True or False: The Transit secrets engine stores the plaintext of data it encrypts.

**95.** True or False: After rotating a Transit encryption key, ciphertext encrypted with an older key version can no longer be decrypted.

---

### Multiple Choice

**96.** What command encrypts the plaintext value `"hello"` (base64-encoded) using the Transit key named `my-key`?

- A) `vault write transit/encrypt/my-key plaintext=$(base64 <<< "hello")`
- B) `vault encrypt transit/my-key -value="hello"`
- C) `vault write transit/cipher/my-key data="hello"`
- D) `vault transit encrypt my-key "hello"`

**97.** What is the purpose of `vault write transit/rewrap/my-key`?

- A) Permanently deletes old key versions
- B) Re-encrypts existing ciphertext under the latest key version without exposing the plaintext
- C) Rotates the key and re-encrypts Vault's own data
- D) Generates a new encryption key from a passphrase

**98.** After performing `vault write transit/keys/my-key/rotate`, what is true about existing ciphertext?

- A) It becomes invalid and must be re-encrypted
- B) It can still be decrypted because old key versions are retained
- C) It is automatically re-encrypted in the background
- D) It expires after 24 hours

**99.** What does a Transit `datakey` operation return?

- A) The Transit key material in plaintext
- B) A new AES key in both plaintext and ciphertext (encrypted by the named transit key)
- C) A signed JWT token
- D) An HMAC digest of the input data

**100.** Which parameter sets automatic key rotation for a Transit key every 30 days?

- A) `vault write transit/keys/my-key auto_rotate_period=720h`
- B) `vault write transit/keys/my-key rotate_ttl=30d`
- C) `vault rotate transit/my-key -schedule=30d`
- D) `vault write sys/transit/schedule my-key 30d`

---

### Multiple Answer (Choose 2)

**101.** Which operations does the Transit secrets engine support? (Choose 2)

- A) Encrypt and decrypt arbitrary data
- B) Persistent storage of secret values
- C) HMAC signing and verification
- D) Managing TLS certificates
- E) Replacing the KV secrets engine

---

### Scenario-Based

**102.** A database contains millions of rows encrypted with an old Transit key version. After a key rotation, the security team wants all data re-encrypted with the latest key version. Which Transit operation should they use?

- A) `vault write transit/keys/my-key/rotate` again
- B) `vault write transit/rewrap/my-key ciphertext=<old_ciphertext>` for each record
- C) `vault write transit/destroy/my-key`
- D) Re-encrypt with `vault write transit/encrypt/my-key`

---

<details>
<summary>Domain 6 Answers</summary>

94. False (Transit never stores plaintext)
95. False (old key versions are retained; old ciphertext can still be decrypted)
96. A
97. B
98. B
99. B
100. A
101. A, C
102. B

</details>

---

## Domain 7: Architecture Fundamentals (Questions 103–117)

### True/False

**103.** True or False: Vault's barrier encrypts all data before it is written to the storage backend.

**104.** True or False: When Vault is sealed, it can read the data in storage but cannot decrypt it.

**105.** True or False: The default number of Shamir key shares required to unseal Vault is 3 out of 5.

**106.** True or False: HCP Vault manages its own unseal process; operators do not need to provide unseal keys.

---

### Multiple Choice

**107.** Which environment variable specifies the address of the Vault server for the CLI?

- A) `VAULT_SERVER`
- B) `VAULT_ADDR`
- C) `VAULT_URL`
- D) `VAULT_HOST`

**108.** What does `vault operator seal` do?

- A) Rotates the master encryption key
- B) Places Vault into a sealed state where it cannot process requests until unsealed
- C) Backs up the storage backend
- D) Disables all auth methods

**109.** Which storage backend is natively integrated into Vault and supports HA without external dependencies?

- A) Consul
- B) MySQL
- C) Raft (Integrated Storage)
- D) Etcd

**110.** What is the primary role of the Vault barrier?

- A) Network firewall for incoming API requests
- B) The encryption layer that protects all data written to the storage backend
- C) The access control enforcement layer for policies
- D) The audit log aggregator

**111.** What does `VAULT_CACERT` specify?

- A) The path to Vault's private key
- B) The path to a CA certificate file for verifying Vault's TLS certificate
- C) The Vault cluster's certificate authority
- D) The certificate used for transit encryption

**112.** Which command checks the current seal status and version of Vault?

- A) `vault health`
- B) `vault operator status`
- C) `vault status`
- D) `vault info`

**113.** What does `VAULT_TOKEN` environment variable do?

- A) Stores the unseal key
- B) Provides the client token for CLI authentication without requiring `vault login`
- C) Sets the root token for initialization
- D) Configures the token TTL

---

### Multiple Answer (Choose 2)

**114.** What happens when Vault starts up in a sealed state? (Choose 2)

- A) All read operations return cached data from the last session
- B) The storage backend is accessible but data is unreadable (encrypted)
- C) Vault cannot service any requests until unsealed
- D) Auth methods continue to function normally
- E) Vault automatically unseals if a valid token is provided

---

### Scenario-Based

**115.** A Vault cluster was restarted after maintenance. The operator runs `vault status` and sees `Sealed: true`. What is the next required step?

- A) Run `vault operator init` to reinitialize
- B) Provide the required number of unseal key shares using `vault operator unseal`
- C) Restart the Vault service again
- D) Provide the root token to unseal

**116.** Your team wants to avoid manual unseal operations after restarts. Which feature allows Vault to automatically unseal using a cloud KMS?

- A) Shamir auto-share
- B) Auto-unseal (using AWS KMS, Azure Key Vault, or GCP CKMS)
- C) Vault Agent unseal plugin
- D) HCP auto-recovery

**117.** A new engineer asks what happens to secrets if the storage backend is compromised. What is the correct answer?

- A) Secrets are exposed because storage holds the plaintext
- B) Secrets remain protected because all data in storage is encrypted by the Vault barrier key
- C) Only KV v1 secrets are encrypted; KV v2 stores plaintext
- D) Secrets are only protected if TLS is enabled

---

<details>
<summary>Domain 7 Answers</summary>

103. True
104. True
105. True (default: 3 of 5)
106. True
107. B
108. B
109. C
110. B
111. B
112. C
113. B
114. B, C
115. B
116. B
117. B

</details>

---

## Domain 8: Deployment Architecture (Questions 118–135)

### True/False

**118.** True or False: HCP Vault Dedicated is a fully managed Vault service where HashiCorp handles infrastructure, upgrades, and backups.

**119.** True or False: Performance replication secondary clusters share the primary cluster's token store and leases.

**120.** True or False: Raft integrated storage requires a separate Consul cluster for coordination.

**121.** True or False: A DR (Disaster Recovery) replication secondary can serve live client traffic during normal operations.

---

### Multiple Choice

**122.** What is the primary operational difference between HCP Vault and self-managed Vault?

- A) HCP Vault only supports KV secrets; self-managed supports all engines
- B) HCP Vault is managed and operated by HashiCorp; self-managed requires the operator to handle infrastructure, upgrades, and HA
- C) HCP Vault uses a different API than self-managed Vault
- D) Self-managed Vault cannot use Raft storage

**123.** In HCP Vault, who is responsible for patching, upgrades, and infrastructure scaling?

- A) The end user/operator
- B) HashiCorp
- C) A third-party managed service provider
- D) The Vault Agent

**124.** What is Raft integrated storage also known as?

- A) External storage
- B) Integrated Storage
- C) Consul backend
- D) File backend

**125.** In a Vault HA cluster with Raft, what happens when the active node fails?

- A) All data is lost until the node recovers
- B) A standby node is elected as the new active node automatically
- C) The cluster enters a sealed state
- D) An operator must manually promote a standby

**126.** Which replication type is designed for geographic redundancy with the ability to promote a secondary to primary during a disaster?

- A) Performance replication
- B) DR (Disaster Recovery) replication
- C) Raft replication
- D) Consul replication

**127.** What is the default number of Shamir key shares generated during `vault operator init`?

- A) 1 key, threshold 1
- B) 3 keys, threshold 2
- C) 5 keys, threshold 3
- D) 10 keys, threshold 5

**128.** What is the purpose of performance replication in Vault Enterprise?

- A) To provide disaster recovery failover
- B) To scale read performance by allowing secondary clusters to serve read requests locally
- C) To replicate audit logs across clusters
- D) To synchronize unseal keys between clusters

**129.** Which command shows the Vault cluster's HA (high availability) status and current leader?

- A) `vault status`
- B) `vault operator raft list-peers`
- C) `vault ha-status`
- D) `vault read sys/ha-status`

---

### Multiple Answer (Choose 2)

**130.** What are valid Vault storage backends? (Choose 2)

- A) Raft (Integrated Storage)
- B) PostgreSQL (direct)
- C) Consul
- D) Redis
- E) S3

**131.** What are key differences between HCP Vault and self-managed Vault? (Choose 2)

- A) HCP Vault does not support the Vault CLI
- B) HCP Vault handles infrastructure management; self-managed requires operator expertise
- C) Self-managed Vault supports auto-unseal; HCP Vault does not
- D) With HCP Vault, operators do not need to manage TLS certificates or unseal keys
- E) HCP Vault only supports the KV secrets engine

---

### Scenario-Based

**132.** A startup wants to use Vault but has no dedicated infrastructure team. They want HashiCorp to handle availability and upgrades. Which deployment option is most appropriate?

- A) Self-managed Vault on bare metal
- B) HCP Vault Dedicated
- C) Vault on Kubernetes with manual HA setup
- D) Vault dev server (`vault server -dev`)

**133.** A company operates Vault in US-East and wants a standby cluster in EU-West that mirrors all configuration and can be activated during a regional outage. Which replication type should they use?

- A) Performance replication
- B) DR replication
- C) Raft replication
- D) Consul sync

**134.** An operator needs to add a new node to a Raft cluster. Which command joins the node to the existing cluster?

- A) `vault operator raft join <leader_api_addr>`
- B) `vault cluster join <node_addr>`
- C) `vault raft add-node <addr>`
- D) `vault operator init -join=<leader>`

**135.** A security requirement mandates that unseal keys must never be held by the operations team. Which Vault feature satisfies this requirement?

- A) Vault Agent auto-auth
- B) Auto-unseal using a cloud KMS (e.g., AWS KMS)
- C) Response wrapping for unseal keys
- D) Disabling Shamir secret sharing

---

<details>
<summary>Domain 8 Answers</summary>

118. True
119. False (performance secondaries do NOT share the primary's token store; DR secondaries mirror the primary)
120. False (Raft is self-contained; no external Consul required)
121. False (DR secondaries cannot serve live client traffic in normal operation)
122. B
123. B
124. B
125. B
126. B
127. C
128. B
129. A (vault status shows HA info) — also acceptable: D
130. A, C
131. B, D
132. B
133. B
134. A
135. B

</details>

---

## Domain 9: Access Management Architecture (Questions 136–150)

### True/False

**136.** True or False: Vault Agent can automatically renew tokens before they expire.

**137.** True or False: Vault Agent requires a human operator to manually authenticate it each time it restarts.

**138.** True or False: The Vault Secrets Operator (VSO) runs as a Kubernetes controller and syncs Vault secrets to Kubernetes Secrets.

**139.** True or False: VSO supports automatic detection of secret changes and can trigger pod restarts.

---

### Multiple Choice

**140.** What core problem does Vault Agent's auto-auth feature solve?

- A) How to rotate encryption keys automatically
- B) The "secret zero" problem — how an application securely obtains its first Vault token without manual intervention
- C) How to replicate secrets across clusters
- D) How to manage Shamir unseal keys

**141.** In a Vault Agent configuration file, what is a "sink"?

- A) A storage backend for Vault data
- B) A destination where the Vault Agent writes the retrieved token or secret (e.g., a file path)
- C) An audit device for logging agent activity
- D) A network endpoint that Vault Agent listens on

**142.** Which auto-auth method does Vault Agent use when running on a Kubernetes pod?

- A) AppRole
- B) AWS IAM
- C) Kubernetes
- D) OIDC

**143.** What is the purpose of Vault Agent templates?

- A) To define Vault policy HCL templates
- B) To render secrets from Vault into configuration files or environment variable files using Go template syntax
- C) To create Kubernetes manifest templates with secrets injected
- D) To template the Vault Agent configuration itself

**144.** What does the Vault Secrets Operator sync Vault secrets into?

- A) Kubernetes ConfigMaps
- B) Kubernetes Secrets
- C) Kubernetes environment variables directly
- D) Pod annotations

**145.** In a Vault Agent config, which stanza defines where the agent writes the obtained token?

- A) `auto_auth { method {} }`
- B) `cache {}`
- C) `auto_auth { sink {} }`
- D) `template {}`

**146.** What is the "secret zero" problem in the context of application secret management?

- A) How to create the first secret in a new Vault deployment
- B) The challenge of securely delivering the initial credential that allows an application to authenticate to Vault
- C) The problem of a secret with a value of zero or null
- D) How to initialize Vault without a root token

---

### Multiple Answer (Choose 2)

**147.** Which are capabilities of Vault Agent? (Choose 2)

- A) Replacing the Vault server in a cluster
- B) Automatic token renewal to prevent expiry
- C) Rendering secrets into config files via templates
- D) Managing Vault storage backends
- E) Issuing new Vault policies

**148.** Which scenarios are best served by the Vault Secrets Operator (VSO) over Vault Agent? (Choose 2)

- A) Running on bare-metal Linux servers
- B) Syncing Vault secrets to native Kubernetes Secrets objects
- C) Rendering secrets into application config files on VMs
- D) Automatically rotating Kubernetes Secrets when the Vault secret changes
- E) Providing auto-auth for non-Kubernetes workloads

---

### Scenario-Based

**149.** An application deployed on AWS EC2 needs to authenticate to Vault without any pre-provisioned credentials. Which Vault Agent auto-auth method should you configure?

- A) `type = "approle"`
- B) `type = "aws"`
- C) `type = "kubernetes"`
- D) `type = "userpass"`

**150.** A team wants secrets stored in Vault to be automatically available as Kubernetes Secrets and wants pods to restart when secrets are rotated. Which tool should they use and why?

- A) Vault Agent — because it runs as a sidecar and writes secrets to a shared volume
- B) Vault Secrets Operator — because it is a Kubernetes-native controller that syncs Vault secrets to K8s Secrets and supports drift detection and rotation triggers
- C) Direct API calls from the application — because it avoids any additional components
- D) KV v2 with response wrapping — because wrapping tokens can be passed to Kubernetes pods

---

<details>
<summary>Domain 9 Answers</summary>

136. True
137. False (auto-auth handles re-authentication automatically)
138. True
139. True
140. B
141. B
142. C
143. B
144. B
145. C
146. B
147. B, C
148. B, D
149. B
150. B

</details>

---

## Quick Reference: Answer Key

| Q | A | Q | A | Q | A | Q | A | Q | A |
|---|---|---|---|---|---|---|---|---|---|
| 1 | T | 31 | B | 61 | B | 91 | B | 121 | F |
| 2 | F | 32 | B | 62 | B | 92 | C | 122 | B |
| 3 | T | 33 | B | 63 | C | 93 | B | 123 | B |
| 4 | T | 34 | A,C | 64 | B | 94 | F | 124 | B |
| 5 | T | 35 | A,C,E | 65 | A | 95 | F | 125 | B |
| 6 | B | 36 | B | 66 | B | 96 | A | 126 | B |
| 7 | B | 37 | A | 67 | A,C | 97 | B | 127 | C |
| 8 | C | 38 | A | 68 | B | 98 | B | 128 | B |
| 9 | B | 39 | B | 69 | B | 99 | B | 129 | A |
| 10 | A | 40 | T | 70 | T | 100 | A | 130 | A,C |
| 11 | B | 41 | F | 71 | F | 101 | A,C | 131 | B,D |
| 12 | C | 42 | F | 72 | T | 102 | B | 132 | B |
| 13 | B | 43 | T | 73 | T | 103 | T | 133 | B |
| 14 | B | 44 | T | 74 | F | 104 | T | 134 | A |
| 15 | B | 45 | C | 75 | B | 105 | T | 135 | B |
| 16 | B,D | 46 | B | 76 | B | 106 | T | 136 | T |
| 17 | C,D | 47 | C | 77 | B | 107 | B | 137 | F |
| 18 | A,C | 48 | B | 78 | B | 108 | B | 138 | T |
| 19 | C | 49 | B | 79 | B | 109 | C | 139 | T |
| 20 | B | 50 | B | 80 | C | 110 | B | 140 | B |
| 21 | A | 51 | C | 81 | C | 111 | B | 141 | B |
| 22 | T | 52 | B | 82 | C | 112 | C | 142 | C |
| 23 | F | 53 | B,D | 83 | B | 113 | B | 143 | B |
| 24 | T | 54 | A,C | 84 | C | 114 | B,C | 144 | B |
| 25 | F | 55 | B | 85 | B,C | 115 | B | 145 | C |
| 26 | B | 56 | B | 86 | B,C | 116 | B | 146 | B |
| 27 | B | 57 | B | 87 | B | 117 | B | 147 | B,C |
| 28 | C | 58 | F | 88 | B | 118 | T | 148 | B,D |
| 29 | C | 59 | T | 89 | B | 119 | F | 149 | B |
| 30 | B | 60 | F | 90 | B | 120 | F | 150 | B |

---

*Sources: [HashiCorp official sample questions](https://developer.hashicorp.com/vault/tutorials/associate-cert-003/associate-questions-003) · [VMExam free samples](https://www.vmexam.com/hashicorp/hashicorp-vault-associate-certification-exam-sample-questions) · [Exam content list](https://developer.hashicorp.com/vault/tutorials/associate-cert-003/associate-review-003)*
