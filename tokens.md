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

Every token has an **accessor** — a secondary identifier created alongside the token. The accessor is a reference to the token but it is **not** the token. You cannot use an accessor to authenticate to Vault.

#### What you CAN do with an accessor

| Action | Command |
|--------|---------|
| List all active tokens (by accessor) | `vault list auth/token/accessors` |
| Look up token metadata without the token value | `vault token lookup -accessor <accessor>` |
| Revoke a token without knowing its value | `vault token revoke -accessor <accessor>` |
| Renew a token without knowing its value | `vault token renew -accessor <accessor>` |
| Check what capabilities a token has on a path | `vault token capabilities -accessor <accessor> <path>` |

#### What you CANNOT do with an accessor
- Use it as a token (it will be rejected)
- Authenticate to Vault
- Create child tokens

#### Why accessors matter for the exam

**Audit and security:** You can list every active token session via `vault list auth/token/accessors` without ever seeing the actual token values. This is the correct way to audit active sessions.

**Incident response:** If a token is compromised but you don't know its value, you can still revoke it using the accessor from the audit log.

```bash
# List all active token accessors
vault list auth/token/accessors

# Look up metadata for a specific accessor (shows policies, TTL, creation time)
# Does NOT return the token value
vault token lookup -accessor abc123def456

# Revoke a token using only its accessor
vault token revoke -accessor abc123def456
```

#### Exam traps

- **Q43 trap:** "Token accessors can be used to revoke a token without knowing the token's value" → **TRUE**. The whole point of accessors is that you don't need the token itself.
- **Q56 trap:** `vault token list` does not exist. The correct command is `vault list auth/token/accessors`.
- Accessors are returned when a token is created — you can also find them in audit logs.

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

---

## Root Token Lifecycle

### What the root token is
A root token has the built-in `root` policy which grants unrestricted access to all of Vault. One is automatically created during `vault operator init`. 

**Best practice:** Revoke it immediately after initial setup. Never keep it active for daily operations.

### Revoking the initial root token
```bash
vault token revoke <root_token>
```

### Regenerating the root token — `vault operator generate-root`

> `vault token create -root` does NOT exist. This is a common exam trap.

The only way to generate a new root token is `vault operator generate-root`, which requires a quorum of unseal key holders (same threshold used to unseal, default 3-of-5). No single person can do it alone.

#### Step-by-step walkthrough

**Step 1 — Initialise the process**

Any operator runs this to start the ceremony. It outputs a nonce (shared with all key holders) and an OTP (one-time password, kept secret by the initiator):

```bash
vault operator generate-root -init

# Output:
# Nonce         abc-123-def-456
# Started       true
# Progress      0/3
# Complete      false
# OTP           <random-32-char-string>   ← save this, you need it at the end
# OTP Length    26
```

**Step 2 — Each unseal key holder provides their key**

Each key holder runs this independently (they only need the nonce, not each other's keys):

```bash
vault operator generate-root -nonce=abc-123-def-456

# Vault prompts:
# Unseal Key (will be hidden): <key holder enters their key>

# Output after each submission:
# Nonce        abc-123-def-456
# Progress     1/3
# Complete     false
```

Repeat until threshold is reached:

```bash
# Second key holder
vault operator generate-root -nonce=abc-123-def-456
# Progress: 2/3

# Third key holder — threshold met
vault operator generate-root -nonce=abc-123-def-456
# Progress: 3/3
# Complete: true
# Encoded Token: <encoded-root-token>
```

**Step 3 — Decode the encoded token**

Only the person who ran `-init` has the OTP, so only they can decode the final root token:

```bash
vault operator generate-root \
    -decode=<encoded-root-token> \
    -otp=<otp-from-step-1>

# Output: <actual_root_token>
```

**Step 4 — Use it, then revoke it immediately**

```bash
export VAULT_TOKEN=<root_token>

# Do your admin work here...

# Revoke it when done
vault token revoke <root_token>
```

#### Other useful commands during the ceremony

```bash
# Check current progress without submitting a key
vault operator generate-root -status

# Cancel the ceremony (any operator can do this)
vault operator generate-root -cancel
```

#### Why the OTP + encoded token design?
The final root token is XOR'd with the OTP before being shown. This means the encoded token alone is useless — you need both the encoded output (which any key holder could see) and the OTP (which only the initiator holds). No single key holder can produce a root token on their own.

---

### Exam summary — Root Tokens

| Fact | Detail |
|------|--------|
| Created automatically at | `vault operator init` |
| Best practice after init | Revoke immediately |
| How to regenerate | `vault operator generate-root` (quorum required) |
| `vault token create -root` | Does NOT exist — exam trap |
| Who can cancel the ceremony | Any operator with access |
| Threshold required | Same as unseal threshold (default 3-of-5) |