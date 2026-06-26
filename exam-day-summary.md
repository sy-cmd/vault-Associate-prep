# Exam Day — Wrong Answers Cheat Sheet

> Read this the morning of June 26 and again before you sit down. These are every concept you got wrong across both practice sessions.

---

## Auth Methods

**Azure AD / corporate SSO / OAuth2 = OIDC — NOT LDAP**
- LDAP = on-prem Active Directory (self-hosted directory server)
- OIDC = cloud identity providers (Azure AD, Google, Okta)

**Token auth method cannot be disabled**
- Every other auth method can be disabled. Token auth is the exception — it is always on.

**AWS auth method handles EC2 — not AppRole**
- AppRole = generic machine auth (any platform)
- AWS = specifically for EC2 instances and IAM roles

**Kubernetes SA parameter = `bound_service_account_names`**
- `allowed_service_accounts` does not exist
- `bound_service_account_names` restricts which Kubernetes service accounts can authenticate

**`vault auth list -detailed` shows accessors for auth methods**
- The `-detailed` flag gives you accessor, options, and config for each method

---

## Vault Policies

**Policy names are case-INSENSITIVE**
- `MyPolicy` and `mypolicy` are the same policy

**`deny` always wins — it overrides every other capability on the same path**
- Even if another policy grants `read`, a `deny` on the same path blocks it

**`list` capability is required to list keys — NOT `read`**
- `read` lets you read values
- `list` lets you see what paths exist

**`patch` = partial update (KV v2 only)**
- `update` = full replacement
- `patch` = update one field without touching the rest

**`+` = exactly one path segment**
- `*` = any number of segments (including zero)
- `kv/data/+/config` matches `kv/data/team/config` but not `kv/data/a/b/config`

---

## Vault Tokens

**`vault token create -root` DOES NOT EXIST**
- To regenerate a root token: `vault operator generate-root -init`
- Requires a quorum of unseal key holders (default 3 of 5)
- The OTP from `-init` is needed to decode the final encoded token

**Root tokens must be revoked after initial setup — never kept active**
- Best practice: revoke after setup, regenerate only when needed

**Batch token = high-throughput, short-lived workloads**
- NOT stored in the backend (data is encoded in the token itself)
- Cannot be renewed
- Periodic token = long-running, renewable indefinitely (different thing)

**Accessors CAN revoke a token without knowing the token value — TRUE**
- `vault token revoke -accessor <accessor>` works without the actual token
- `vault list auth/token/accessors` lists all active sessions (no token values exposed)
- `vault token lookup -accessor <accessor>` shows metadata only

**`vault token list` does NOT exist**
- Correct command: `vault list auth/token/accessors`

**Service tokens are revoked when their parent is revoked**
- Orphan tokens have no parent — they survive parent revocation

---

## Vault Leases

**KV secrets do NOT have leases**
- Dynamic secrets (database creds, AWS creds) have leases
- KV v1 and KV v2 do not — `lease_duration` in the response is just informational

**Leases CANNOT be renewed past `max_ttl`**
- When max_ttl is hit: renewal fails, credential is revoked, you must request a new one

**Bulk revoke uses the `-prefix` flag**
```bash
vault lease revoke -prefix database/creds/readonly/   # all leases at this path
vault lease revoke <lease_id>                          # one specific lease
```

**List active leases — exact command:**
```bash
vault list sys/leases/lookup/aws/creds/
```
- `vault lease list` does NOT exist
- It lives under `sys/leases/lookup/` not under the engine path

---

## Secrets Engines

**Cubbyhole is PRIVATE per token — NOT shared**
- Each token gets its own isolated cubbyhole
- Deleting the token deletes the cubbyhole

**Response wrapping tokens are SINGLE-USE**
- After one unwrap, the token is gone
- The pipeline operator cannot see the secret because only the recipient can unwrap

**`vault kv delete` = soft delete (recoverable with `vault kv undelete`)**
**`vault kv destroy` = permanent (cannot recover)**

**`vault kv rollback` copies old version as a NEW current version**
- It does not revert the engine or cluster state
- The old version data becomes version N+1

**KV v2 retains 10 versions by default**

---

## Encryption as a Service (Transit)

**Rotating a Transit key does NOT break old ciphertext**
- Old key versions are retained
- `vault:v1:...` ciphertext still decrypts even after rotating to v2, v3, etc.
- The ciphertext prefix tells Vault which version to use

**`rewrap` re-encrypts under the latest key WITHOUT exposing plaintext**
```bash
vault write transit/rewrap/my-key ciphertext="vault:v1:abc..."
# Returns vault:v2:... — no plaintext ever leaves Vault
```

**`datakey` returns a new AES key in BOTH plaintext AND ciphertext**
- Use the plaintext to encrypt data locally, then discard it
- Store the ciphertext — it is used later to recover the plaintext key

**Auto-rotation:**
```bash
vault write transit/keys/my-key/config auto_rotate_period=720h  # 30 days
```

---

## Architecture

**`VAULT_TOKEN` provides the client token for CLI auth — NOT the unseal key**
- `VAULT_ADDR` = server address
- `VAULT_TOKEN` = your auth token (skips `vault login`)
- `VAULT_CACERT` = CA certificate path for TLS verification

**`vault operator seal` = puts Vault into sealed state**
- Nothing is backed up, no keys are rotated
- Backups: `vault operator raft snapshot save`
- Unsealing after: `vault operator unseal`

**Default init: 5 key shares, threshold 3**
- `vault operator init` generates 5 unseal keys, requires 3 to unseal

**Vault barrier encrypts everything before writing to storage**
- If storage is compromised, data is still encrypted

---

## Deployment Architecture

**Raft (Integrated Storage) does NOT require Consul**
- Raft is self-contained — it replaced the need for an external Consul backend
- Consul is still a valid storage backend but is not required

**DR secondary = standby ONLY — cannot serve live client traffic**
- DR secondary: mirrors everything, activated only during a disaster
- Performance secondary: can serve read requests during normal operations

**Auto-unseal = cloud KMS (AWS KMS, Azure Key Vault, GCP CKMS)**
- Vault Agent handles app authentication — it does NOT handle unsealing
- Auto-unseal lets Vault unseal itself on restart without operator intervention

**HCP Vault = fully managed by HashiCorp (infra, upgrades, backups, TLS, unseal)**

**`vault operator raft join <leader_addr>` adds a node to a Raft cluster**

---

## Access Management

**Vault Agent auto-auth solves the "secret zero" problem**
- Secret zero = how does an app get its first credential without a human handing it over?
- Auto-auth uses the environment (Kubernetes JWT, AWS IAM, etc.) to authenticate automatically
- NOT about replication or key rotation

**Vault Agent auto-auth re-authenticates automatically on restart**
- No human intervention needed between restarts

**VSO (Vault Secrets Operator) syncs secrets into Kubernetes Secrets objects**
- Vault Agent = sidecar, writes to files/env vars
- VSO = Kubernetes controller, syncs to native K8s Secrets, triggers pod restarts on rotation

**For AWS EC2 auto-auth: `type = "aws"`**
- For Kubernetes pods: `type = "kubernetes"`

---

## Quick Command Reference — Ones That Tripped You

| What you want | Correct command |
|---|---|
| Regenerate root token | `vault operator generate-root -init` |
| List all active token sessions | `vault list auth/token/accessors` |
| Revoke token without knowing value | `vault token revoke -accessor <accessor>` |
| List leases at a path | `vault list sys/leases/lookup/aws/creds/` |
| Bulk revoke all leases at a path | `vault lease revoke -prefix aws/creds/` |
| Re-encrypt ciphertext after key rotation | `vault write transit/rewrap/my-key ciphertext=<old_ct>` |
| Auto-rotate transit key every 30 days | `vault write transit/keys/my-key/config auto_rotate_period=720h` |
| Add node to Raft cluster | `vault operator raft join <leader_addr>` |
| Show auth method accessors | `vault auth list -detailed` |
| Check token capabilities on a path | `vault token capabilities <token> <path>` |

---

## Final Score Summary

| Session | Score | Result |
|---|---|---|
| 150-question practice | 126/150 (84%) | Pass |
| 60-question mock exam | 49/60 (82%) | Pass |

**Pass mark on the real exam: 42/60 (70%)**
You are 12 questions above the pass mark. You are ready.

Good luck tomorrow.
