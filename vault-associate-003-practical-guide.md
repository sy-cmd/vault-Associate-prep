# Vault Associate (003) - Comprehensive Practical Study Guide

Comprehensive hands-on practice guide for the HashiCorp Vault Associate certification exam. Covers all exam objectives with detailed CLI commands and expected outputs.

**Exam Version**: Vault 1.16+
**Last Updated**: May 2026

---

## Table of Contents

1. [KV Secrets Engine - Complete Practice](#1-kv-secrets-engine)
2. [Transit Secrets Engine](#2-transit-secrets-engine)
3. [Token Creation - All Types](#3-token-creation)
4. [Response Wrapping](#4-response-wrapping)
5. [Database Dynamic Secrets](#5-database-dynamic-secrets)
6. [Policies](#6-policies)
7. [Authentication Methods](#7-authentication-methods)
8. [Vault Architecture Basics](#8-vault-architecture-basics)
9. [Database Secrets Engine](#9-database-secrets-engine)
10. [Exam Tips & Cheat Sheet](#10-exam-tips--cheat-sheet)

---

## 1. KV Secrets Engine

### 1.1 Enable KV Secrets Engines

```bash
# Enable KV v1 (no versioning)
vault secrets enable -path=kv-v1 kv

# Enable KV v2 (with versioning) - default for secret/
vault secrets enable -path=kv-v2 -version=2 kv

# Enable at custom path
vault secrets enable -path=projects/myapp kv

# Verify enabled engines
vault secrets list -detailed

# Check specific engine version
vault read sys/mounts/kv-v2
# Look for: "options": {"version": "2"}
```

### 1.2 Write Secrets (KV v1 & v2)

```bash
# Write a secret (KV v2)
vault kv put kv-v2/dev api_key="abc123xyz" db_password="SecurePass123"

# Write with -mount flag (alternative syntax for KV v2)
vault kv put -mount=kv-v2 web-app api_key="newkey456" db_password="newpass"

# Write multiple key-value pairs
vault kv put secret/prod/config \
  AWS_ACCESS_KEY="AKIAIOSFODNN7EXAMPLE" \
  AWS_SECRET_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" \
  DATABASE_URL="postgresql://user:pass@localhost:5432/mydb"

# Write JSON data from file
echo '{"api_key": "secret123", "region": "us-west-2"}' > data.json
vault kv put secret/web-app @data.json
```

### 1.3 Read Secrets

```bash
# Read latest version (KV v2)
vault kv get kv-v2/dev

# Read specific version
vault kv get -version=1 kv-v2/dev

# Read with -mount flag
vault kv get -mount=kv-v2 web-app

# Read metadata only
vault kv metadata get kv-v2/web-app

# Read all versions list
vault kv versions list kv-v2/web-app

# Check if secret exists (returns error if not found)
vault kv get kv-v2/prod 2>/dev/null && echo "EXISTS" || echo "NOT FOUND"
```

### 1.4 Update Secrets (Versioning)

```bash
# Update creates a new version (KV v2)
vault kv put kv-v2/dev api_key="updated-key-789" db_password="UpdatedPass"
# Creates version 2

# Update again
vault kv put kv-v2/dev api_key="new-key-999" db_password="NewPass123"
# Creates version 3

# Verify versions
vault kv versions list kv-v2/dev
vault kv get kv-v2/dev
vault kv get -version=1 kv-v2/dev
vault kv get -version=2 kv-v2/dev
```

### 1.5 Patch (Partial Update - KV v2 Only)

```bash
# Patch only updates specific fields (doesn't replace entire secret)
vault kv patch kv-v2/dev api_key="patched-key-111"

# Patch with multiple fields
vault kv patch kv-v2/config \
  API_VERSION="v2" \
  TIMEOUT="30s"

# Compare with put:
# - vault kv put: FULL replacement (all fields required)
# - vault kv patch: PARTIAL update (only changed fields)

# Verify patch created new version
vault kv get kv-v2/dev
```

### 1.6 Metadata Configuration

```bash
# Set max versions for ALL secrets at this path
vault kv metadata put -max-versions=5 kv-v2/dev

# Set custom metadata
vault kv metadata put -custom-metadata=Environment="production" \
  -custom-metadata=Team="platform" \
  kv-v2/dev

# Configure delete_version_after (auto-delete after time)
vault kv metadata put -delete-version-after=24h kv-v2/tmp

# Read metadata
vault kv metadata get kv-v2/dev

# Check config at engine level
vault read kv-v2/config
```

### 1.7 Soft Delete (Mark for Deletion)

```bash
# Delete latest version
vault kv delete kv-v2/dev

# Delete specific versions
vault kv delete -versions=2 kv-v2/dev
vault kv delete -versions="2,3" kv-v2/dev

# Verify deletion (shows deletion_time)
vault kv metadata get kv-v2/dev

# Try reading deleted version
vault kv get kv-v2/dev
# Output: No value found at secret/data/dev (version is soft deleted)

# Read deleted version
vault kv get -version=2 kv-v2/dev
# Output: Version 2 is still accessible but marked as deleted
```

### 1.8 Undelete (Recover Deleted Version)

```bash
# Undelete single version
vault kv undelete -versions=2 kv-v2/dev

# Undelete multiple versions
vault kv undelete -versions="2,3" kv-v2/dev

# Undelete all versions
vault kv undelete -versions=all kv-v2/dev

# Verify recovery
vault kv get kv-v2/dev
vault kv metadata get kv-v2/dev
```

### 1.9 Permanent Destroy (Cannot Recover)

```bash
# Destroy specific versions (permanent)
vault kv destroy -versions=2 kv-v2/dev

# Destroy multiple versions
vault kv destroy -versions="2,3" kv-v2/dev

# Check destroyed status in metadata
vault kv metadata get kv-v2/dev
# destroyed: true for those versions

# Try reading destroyed version
vault kv get -version=2 kv-v2/dev
# Output: No value found (permanently destroyed)
```

### 1.10 Delete Metadata (Delete Everything)

```bash
# Delete ALL versions and metadata (complete cleanup)
vault kv metadata delete kv-v2/project-x

# This permanently removes:
# - All secret versions
# - All metadata
# - All custom metadata

# Verify
vault kv get kv-v2/project-x
# Output: No such secret
vault kv metadata get kv-v2/project-x
# Output: No such secret
```

### 1.11 Rollback (Revert to Previous Version)

```bash
# Rollback to specific version (creates new version with old data)
vault kv rollback -version=1 kv-v2/dev

# After rollback:
# - New version created with data from version 1
# - Current version becomes version N+1
vault kv versions list kv-v2/dev
```

### 1.12 Check-and-Set (CAS) Operations

```bash
# Enable CAS required on a path
vault kv metadata put -cas-required kv-v2/critical

# Write with CAS (only succeeds if version matches)
vault kv put -cas-version=3 kv-v2/critical api_key="new-key"
# Fails if version 3 is not current

# Read current version for CAS
vault kv get -field=version kv-v2/critical
```

---

## 2. Transit Secrets Engine

### 2.1 Enable Transit Engine

```bash
# Enable transit at default path
vault secrets enable transit

# Enable at custom path
vault secrets enable -path=encryption transit

# Verify
vault secrets list | grep transit
```

### 2.2 Create Encryption Keys

```bash
# Create named encryption key
vault write -f transit/keys/payment-keys

# Create key with specific type
vault write -f transit/keys/my-key \
    type=aes256-gcm96

# Available key types:
# - aes256-gcm96 (default)
# - aes128-gcm96
# - chacha20-poly1305
# - ed25519
# - ecdsa-p256, ecdsa-p384, ecdsa-p521
# - rsa-2048, rsa-3072, rsa-4096
# - hmac

# List all keys
vault list transit/keys/

# Read key info
vault read transit/keys/payment-keys
```

### 2.3 Encrypt Data

```bash
# IMPORTANT: Plaintext MUST be base64 encoded
vault write transit/encrypt/payment-keys \
    plaintext=$(echo "4111 1111 1111 1111" | base64)

# Encrypt and store ciphertext
CIPHERTEXT=$(vault write transit/encrypt/payment-keys \
    plaintext=$(echo "credit-card-number" | base64) \
    -format=json | jq -r '.data.ciphertext')

echo $CIPHERTEXT

# Encrypt with key version specified
vault write transit/encrypt/payment-keys \
    plaintext=$(echo "data" | base64) \
    key_version=1

# Encrypt large data
base64 -i large-file.bin > data.b64
vault write transit/encrypt/payment-keys \
    plaintext=$(cat data.b64)
```

### 2.4 Decrypt Data

```bash
# Decrypt ciphertext
vault write transit/decrypt/payment-keys \
    ciphertext=$CIPHERTEXT

# Extract and decode plaintext
PLAINTEXT=$(vault write -field=plaintext transit/decrypt/payment-keys \
    ciphertext=$CIPHERTEXT)

echo $PLAINTEXT | base64 -d

# Full one-liner decrypt
vault write -field=plaintext transit/decrypt/payment-keys \
    ciphertext=$CIPHERTEXT | base64 -d
```

### 2.5 Key Rotation

```bash
# Rotate encryption key (creates new version)
vault write -f transit/keys/payment-keys/rotate

# Verify new version
vault read transit/keys/payment-keys
# Key shows: "keys": {"1": "...", "2": "..."}
# latest_version: 2

# Encrypt with new key (auto-uses latest)
vault write transit/encrypt/payment-keys \
    plaintext=$(echo "new-data" | base64)
# Returns: ciphertext starts with "vault:v2:"

# Old ciphertext (vault:v1:) still decryptable with key version 1
```

### 2.6 Rewrap (Upgrade ciphertext to new key)

```bash
# Rewrap old ciphertext with latest key version
vault write transit/rewrap/payment-keys \
    ciphertext=$CIPHERTEXT

# New ciphertext uses latest key version
# vault:v1:... -> vault:v2:...

# Rewrap with specific key version
vault write transit/rewrap/payment-keys \
    ciphertext=$CIPHERTEXT \
    key_version=2
```

### 2.7 Auto-Rotate Configuration

```bash
# Configure auto-rotation every 24 hours
vault write transit/keys/payment-keys/config \
    auto_rotate_period=24h

# Configure auto-rotation every 30 days
vault write transit/keys/payment-keys/config \
    auto_rotate_period=720h

# Disable auto-rotation
vault write transit/keys/payment-keys/config \
    auto_rotate_period=0

# Verify configuration
vault read transit/keys/payment-keys
```

### 2.8 Key Configuration

```bash
# Set minimum decryption version (security hardening)
vault write transit/keys/payment-keys/config \
    min_decryption_version=2

# After this, ciphertext from version 1 cannot be decrypted
vault write transit/decrypt/payment-keys \
    ciphertext="vault:v1:..."
# Error: "cannot decrypt with version 1, minimum is 2"

# Set minimum encryption version
vault write transit/keys/payment-keys/config \
    min_encryption_version=2

# Allow plaintext backup
vault write transit/keys/payment-keys/config \
    allow_plaintext_backup=true

# Make key deletable
vault write transit/keys/payment-keys/config \
    deletion_allowed=true

# Delete key
vault delete transit/keys/payment-keys
```

### 2.9 Datakey Generation

```bash
# Generate plaintext datakey (returns both plaintext and wrapped)
vault write -f transit/datakey/plainkeys/payment-methods

# Output:
# Key           Value
# plaintext     yHBiiQ5DRq0NC87/YZb6KOx5JLxx+8tqZYit09ao+cg=
# ciphertext    vault:v5:bEGOqiwiWG4IZqSVOy4BZBbGdCNinMYtUGeH5Zj0lcm...
# key_version    5

# Generate wrapped-only datakey (for audit compliance)
vault write -f transit/datakey/wrappedkeys/payment-methods

# Output:
# ciphertext    vault:v5:...
# key_version    5
# (no plaintext returned)

# Use case: Encrypt large files locally without sending to Vault
# 1. Get datakey from Vault
# 2. Encrypt file with plaintext datakey locally
# 3. Store ciphertext of datakey alongside encrypted file
# 4. To decrypt: unwrap datakey ciphertext with Vault
```

### 2.10 HMAC and Hash Operations

```bash
# Generate HMAC for data verification
vault write transit/hmac/payment-keys \
    input=$(echo "important-data" | base64)

# Verify HMAC
vault write transit/verify/payment-keys \
    input=$(echo "important-data" | base64) \
    hmac=<hmac-from-above>

# Generate hash
vault write transit/hash/payment-keys \
    input=$(echo "data-to-hash" | base64)
```

### 2.11 Signing Operations (for non-HMAC keys)

```bash
# Sign data (requires ed25519, ecdsa, or rsa key)
vault write transit/sign/payment-keys \
    input=$(echo "document" | base64)

# Verify signature
vault write transit/verify/payment-keys \
    input=$(echo "document" | base64) \
    signature=<signature-from-above>
```

---

## 3. Token Creation

### 3.1 Basic Token Types

```bash
# Create default service token
vault token create

# Create batch token (no renewal, ephemeral)
vault token create -type=batch

# Create orphan token (no parent relationship)
vault token create -orphan

# Create child token (inherits from parent)
vault token create -policy=default

# Verify token info
vault token lookup
vault token lookup <token_id>
```

### 3.2 TTL Configuration

```bash
# Create token with 1 hour TTL
vault token create -ttl=1h

# Create token with 30 minutes TTL
vault token create -ttl=30m

# Create token with explicit max TTL (hard limit)
vault token create -ttl=1h -explicit-max-ttl=24h

# Create token with max TTL
vault token create -ttl=1h -max-ttl=24h

# Create token with no expiration (use carefully!)
vault token create -ttl=0

# Check token TTL
vault token lookup
# Output: "expire_time": "2024-01-01T12:00:00.000000Z"
```

### 3.3 Token Policies

```bash
# Create token with specific policies
vault token create -policy=my-policy -policy=other-policy

# Create token without default policy
vault token create -no-default-policy

# Create token with only default policy
vault token create -policy=default

# List available policies
vault policy list

# Read a policy
vault policy read my-policy
```

### 3.4 Token Roles

```bash
# Define a token role with TTL constraints
vault write auth/token/roles/my-role \
    allowed_policies="default,app-policy" \
    ttl="1h" \
    max_ttl="24h" \
    orphan=false

# Create token from role
vault token create -role=my-role

# Create periodic token role (renewable without explicit renewal)
vault write auth/token/roles/periodic-role \
    period="1h"
# Token auto-renews every hour as long as it's used

# Create explicit-max-ttl role
vault write auth/token/roles/explicit-role \
    explicit_max_ttl="24h"

# Create batch token role
vault write auth/token/roles/batch-role \
    allowed_policies="app-policy" \
    token_type=batch

# List token roles
vault list auth/token/roles/

# Read role
vault read auth/token/roles/my-role

# Delete role
vault delete auth/token/roles/my-role
```

### 3.5 Token Accessors

```bash
# Token accessor allows limited operations without seeing token ID

# List all token accessors
vault list auth/token/accessors

# Look up token by accessor (metadata only)
vault token lookup -accessor <accessor>

# Renew token by accessor
vault token renew -accessor <accessor>

# Renew with specific increment
vault token renew -accessor <accessor> -increment=1h

# Revoke token by accessor
vault token revoke -accessor <accessor>

# Create token with accessor (delegation)
vault token create -accessor <existing_accessor> -policy="my-policy"
```

### 3.6 Token Hierarchies (Parent-Child)

```bash
# Create parent token
PARENT_TOKEN=$(vault token create -ttl=2h -format=json | jq -r '.auth.client_token')
echo "Parent: $PARENT_TOKEN"

# Create child token (inherits policies, revoked when parent revoked)
CHILD_TOKEN=$(VAULT_TOKEN=$PARENT_TOKEN vault token create -ttl=1h -format=json | jq -r '.auth.client_token')
echo "Child: $CHILD_TOKEN"

# Create orphan child (bypasses parent inheritance)
ORPHAN_CHILD=$(VAULT_TOKEN=$PARENT_TOKEN vault token create -orphan -format=json | jq -r '.auth.client_token')

# Verify parent-child relationship
vault token lookup $CHILD_TOKEN
# Shows: "parent": "<parent_token_id>"

# Revoke parent - all children revoked
vault token revoke $PARENT_TOKEN

# Verify child is revoked
VAULT_TOKEN=$CHILD_TOKEN vault token lookup
# Error: bad token
```

### 3.7 Token Metadata

```bash
# Add metadata to token
vault token create -metadata="environment=prod" -metadata="team=platform"

# Add multiple metadata fields
vault token create -metadata=environment="production" \
    -metadata=team="platform" \
    -metadata=application="webapp"

# View token metadata
vault token lookup
# Shows: "meta": {"environment": "prod", "team": "platform"}

# Use metadata in policies
# In policy: {{ token.metadata.environment }}
```

### 3.8 Token Display Name and External ID

```bash
# Set display name
vault token create -display-name="ci-pipeline"

# Set external ID (for external systems)
vault token create -external-entity-id="github-runner-123"

# Create token with use limit (auto-revoke after N uses)
vault token create -use-limit=5

# Verify token use count
vault token lookup
# Shows: "num_uses": 0
```

### 3.9 Token Renewal and Revocation

```bash
# Renew own token
vault token renew

# Renew with specific increment
vault token renew -increment=1h

# Renew another token
vault token renew <token_id>

# Renew by accessor
vault token renew -accessor="<accessor>"

# Revoke own token
vault token revoke -self

# Revoke by token ID
vault token revoke <token_id>

# Revoke by accessor
vault token revoke -accessor="<accessor>"

# Revoke all children of current token
vault token revoke -self -path

# Revoke orphan token (doesn't affect children)
vault token revoke-orphan <orphan_token_id>

# Revoke by prefix
vault token revoke -prefix auth/token/create/
```

### 3.10 Root Tokens

```bash
# Create root token (requires existing root or via unwrap)
vault token create -root

# Generate root token from unseal keys (emergency)
vault operator generate-root -addr=$VAULT_ADDR

# Note: Root tokens should only be used for:
# - Initial setup
# - Emergency recovery
# - Periodic maintenance tasks
```

---

## 4. Response Wrapping

### 4.1 Wrap Secret with TTL

```bash
# Wrap a secret with 2 minute TTL
vault kv get -wrap-ttl=120s kv-v2/dev

# Output:
# Wrapped response
# Key                    Value
# ---                    -----
# token                  hvs.CAESIK9v...Ft7pQ
# ttl                    2m
# creation_time          2024-01-01T00:00:00Z
# creation_ttl            2m

# Store wrapping token and send to recipient
WRAP_TOKEN="hvs.CAESIK9v...Ft7pQ"
```

### 4.2 Unwrap Wrapped Token

```bash
# Unwrap with token
VAULT_TOKEN="<wrap_token>" vault unwrap

# Unwrap directly
vault unwrap -token="<wrap_token>"

# Use unwrap to get secret data
vault unwrap -field=version kv-v2/dev

# Unwrap and parse JSON
vault unwrap -format=json | jq '.data'
```

### 4.3 Rewrap Token (Extend TTL)

```bash
# Rewrap to get new wrapping token
VAULT_TOKEN="<existing_wrap_token>" vault rewrap

# New token returned with full TTL
# Original token is consumed (cannot be reused)

# Use case: Recipient needs more time to retrieve
```

### 4.4 Wrap Custom Data

```bash
# Wrap arbitrary data
vault write -wrap-ttl=60s cubbyhole/admin-token secret="my-secret"

# Wrap with custom response
vault write -wrap-ttl=120s -field=token auth/token/create policy=my-policy

# Lookup wrapping token info
vault token lookup -token="<wrap_token>"

# Shows:
# - creation_ttl
# - creation_time
# - expire_time
# - num_uses
```

### 4.5 Wrapping Token Use Cases

```bash
# Use case 1: Secure token distribution
# Admin wraps new token for developer
vault kv get -wrap-ttl=1h secret/api-keys > wrapped-response.json
# Send file via secure channel

# Developer unwraps to get token
vault unwrap < wrapped-response.json

# Use case 2: One-time delivery
# Wrapping token can only be used once
# After unwrap, token is invalidated

# Use case 3: Auditing
# Wrapping creates audit trail
# Shows who created token and when it was unwrapped
```

### 4.6 Cubbyhole for Wrapping

```bash
# Store wrapped token in cubbyhole (temporary storage)
vault write cubbyhole/wrapped api_key="secret-value"

# Retrieve from cubbyhole
vault read cubbyhole/wrapped

# Cubbyhole is per-token, private storage
# Token deletion removes all cubbyhole data

# Use with wrapping
vault read -wrap-ttl=60s cubbyhole/sensitive-data
```

---

## 5. Database Dynamic Secrets

### 5.1 Enable Database Secrets Engine

```bash
# Enable database secrets engine
vault secrets enable database

# Enable at custom path
vault secrets enable -path=db-secrets database

# Verify
vault secrets list | grep database
```

### 5.2 Configure Database Connection

```bash
# Configure PostgreSQL connection
vault write database/config/postgres-demo \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/mydb" \
    username="vault_admin" \
    password="admin123"

# Configure with SSL
vault write database/config/postgres-prod \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="app-readonly" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/mydb?sslmode=require" \
    username="vault_admin" \
    password="admin123" \
    tls=true

# Configure MySQL
vault write database/config/mysql-prod \
    plugin_name="mysql-database-plugin" \
    allowed_roles="*" \
    connection_url="{{username}}:{{password}}@tcp(localhost:3306)/appdb" \
    username="vault_admin" \
    password="admin123"

# List configurations
vault list database/config/

# Read configuration
vault read database/config/postgres-demo

# Delete configuration
vault delete database/config/postgres-demo
```

### 5.3 Rotate Root Credentials

```bash
# Rotate root credentials (managed by Vault)
vault write -force database/rotate-root/postgres-demo

# After rotation:
# - Old password is invalidated
# - New password stored securely
# - Only Vault knows the password
```

### 5.4 Create Dynamic Roles

```bash
# Create readonly.sql for dynamic role
cat > readonly.sql << 'EOF'
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO "{{name}}";
EOF

# Create dynamic role
vault write database/roles/dynamic-app-role \
    db_name="postgres-demo" \
    creation_statements=@readonly.sql \
    default_ttl="1h" \
    max_ttl="24h"

# Create role with multiple statements
vault write database/roles/app-readonly \
    db_name="postgres-demo" \
    creation_statements='["CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';", "GRANT CONNECT ON DATABASE appdb TO \"{{name}}\";", "GRANT USAGE ON SCHEMA public TO \"{{name}}\";"]' \
    default_ttl="1h" \
    max_ttl="8h"

# List roles
vault list database/roles/

# Read role
vault read database/roles/dynamic-app-role

# Update role
vault write database/roles/dynamic-app-role \
    default_ttl="2h" \
    max_ttl="12h"

# Delete role
vault delete database/roles/dynamic-app-role
```

### 5.5 Create Static Roles

```bash
# Create static role (password rotation for existing user)
vault write database/static-roles/static-app-role \
    db_name="postgres-demo" \
    username="legacy_app" \
    rotation_period="24h"

# Create with custom rotation statements
vault write database/static-roles/static-app-role \
    db_name="postgres-demo" \
    username="legacy_app" \
    rotation_period="24h" \
    rotation_statements="ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"

# Create with initial password
vault write database/static-roles/static-app-role \
    db_name="postgres-demo" \
    username="legacy_app" \
    rotation_period="24h" \
    rotation_statements="ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';" \
    password="oldpassword123"

# List static roles
vault list database/static-roles/

# Read static role
vault read database/static-roles/static-app-role

# Delete static role
vault delete database/static-roles/static-app-role
```

### 5.6 Request Dynamic Credentials

```bash
# Get dynamic credentials
vault read database/creds/dynamic-app-role

# Output:
# Key                Value
# ---                -----
# lease_id           database/creds/dynamic-app-role/xyz123
# lease_duration     1h
# username           v-dynamic-app-role-abc123
# password           A1a-xxxxxxxxxxxx

# Store in variables
CREDS=$(vault read database/creds/dynamic-app-role -format=json | jq '.data')
USERNAME=$(echo $CREDS | jq -r '.username')
PASSWORD=$(echo $CREDS | jq -r '.password')
```

### 5.7 Request Static Credentials

```bash
# Get static credentials
vault read database/static-creds/static-app-role

# Output:
# Key                Value
# ---                -----
# lease_id           database/static-creds/static-app-role/xyz123
# lease_duration     24h
# username           legacy_app
# password           (current rotated password)

# Static credentials don't change until rotated
# rotation_period determines when Vault rotates password
```

### 5.8 Lease Management

```bash
# List active leases
vault list sys/leases/lookup/database/creds/

# Look up lease
vault lease lookup database/creds/dynamic-app-role/<lease_id>

# Renew lease (extend TTL)
vault lease renew database/creds/dynamic-app-role/<lease_id>
vault lease renew -increment=2h database/creds/dynamic-app-role/<lease_id>

# Revoke lease (immediately invalidate credentials)
vault lease revoke database/creds/dynamic-app-role/<lease_id>

# Revoke all dynamic credentials for a role
vault lease revoke -prefix database/creds/dynamic-app-role

# Revoke all database leases
vault lease revoke -prefix database/

# Force rotation (for static roles)
vault write -force database/rotate-role/static-app-role
```

### 5.9 Cleanup

```bash
# Revoke all dynamic credentials
vault lease revoke -prefix database/creds/

# Revoke all static credentials
vault lease revoke -prefix database/static-creds/

# Delete roles
vault delete database/roles/dynamic-app-role
vault delete database/static-roles/static-app-role

# Delete configuration
vault delete database/config/postgres-demo

# Disable secrets engine
vault secrets disable database
```

---

## 6. Policies

### 6.1 Policy Syntax Basics

```bash
# Policy format (HCL)
path "kv-v2/data/app/*" {
  capabilities = ["read", "list"]
}

path "kv-v2/data/app/config" {
  capabilities = ["create", "read", "update", "delete"]
}
```

### 6.2 Create Policies

```bash
# Create policy from file
vault policy write app-policy policy.hcl

# Create policy from stdin
vault policy write app-policy -<<EOF
path "kv-v2/data/app/*" {
  capabilities = ["read", "list"]
}

path "kv-v2/data/app/config" {
  capabilities = ["create", "update"]
}
EOF

# Create policy for KV secrets
vault policy write kv-policy -<<EOF
path "kv-v2/data/*" {
  capabilities = ["read"]
}

path "kv-v2/data/production/*" {
  capabilities = ["read", "list"]
}

path "kv-v2/metadata/*" {
  capabilities = ["list"]
}
EOF

# Create policy for transit
vault policy write transit-policy -<<EOF
path "transit/encrypt/*" {
  capabilities = ["update"]
}

path "transit/decrypt/*" {
  capabilities = ["update"]
}

path "transit/keys/*" {
  capabilities = ["list", "read"]
}
EOF

# Create policy for database
vault policy write db-policy -<<EOF
path "database/creds/readonly" {
  capabilities = ["read"]
}

path "database/roles" {
  capabilities = ["read", "list"]
}
EOF
```

### 6.3 Policy Capabilities

```bash
# Available capabilities
# - read    : Read data
# - create  : Create new secrets
# - update  : Update existing secrets
# - delete  : Delete secrets
# - list    : List secret paths
# - patch   : Partial update (KV v2)
# - sudo    : Access paths requiring sudo
# - deny    : Explicitly deny access

# Example: Read-only policy
vault policy write read-only -<<EOF
path "kv-v2/data/*" {
  capabilities = ["read"]
}

path "kv-v2/data/public/*" {
  capabilities = ["read", "list"]
}
EOF

# Example: Read-write policy
vault policy write read-write -<<EOF
path "kv-v2/data/*" {
  capabilities = ["read", "create", "update", "delete", "list"]
}

path "kv-v2/metadata/*" {
  capabilities = ["list", "read"]
}
EOF

# Example: Admin policy
vault policy write admin -<<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}
EOF
```

### 6.4 Wildcard Paths

```bash
# Single segment wildcard
path "kv-v2/data/app/*" {
  capabilities = ["read"]
}

# Multi-segment wildcard
path "kv-v2/data/apps/*/config" {
  capabilities = ["read"]
}

# Recursive wildcard
path "kv-v2/data/**" {
  capabilities = ["read"]
}

# Named wildcard
path "kv-v2/data/foo/*" {
  capabilities = ["read"]
}
# Matches: kv-v2/data/foo/bar, kv-v2/data/foo/baz/xyz
```

### 6.5 Policy Variables

```bash
# Token information in policies
path "kv-v2/data/{{identity.entity.aliases.auth_userpass_<mount accessor>.name}}/*" {
  capabilities = ["read", "create", "update"]
}

# Using path helpers
path "kv-v2/data/app/{{ partition }}/*" {
  capabilities = ["read"]
}

# Entity and group information
path "secret/data/{{ identity.entity.id }}/*" {
  capabilities = ["create", "read", "update"]
}

path "secret/data/team/{{ identity.groups.names.mobile }}/*" {
  capabilities = ["read"]
}
```

### 6.6 List and Manage Policies

```bash
# List all policies
vault policy list

# Read a policy
vault policy read default

# Read root policy
vault policy read root

# Update policy
vault policy write my-policy updated-policy.hcl

# Delete policy
vault policy delete my-policy

# Test policy with -output-policy flag
vault kv put -output-policy kv-v2/data/app/config api_key="test"
# Shows ACL policy needed to run command
```

### 6.7 Default and Built-in Policies

```bash
# Read default policy
vault policy read default

# Default policy grants:
# - Read own token
# - Renew own token
# - Revoke own token
# - Access own cubbyhole

# Root policy grants full access
vault policy read root

# Every token must have either:
# - A policy that grants access
# - Sudo capability on the path
```

---

## 7. Authentication Methods

### 7.1 Enable Auth Methods

```bash
# Enable token auth (enabled by default)
vault auth enable token

# Enable userpass
vault auth enable userpass

# Enable approle
vault auth enable approle

# Enable kubernetes
vault auth enable kubernetes

# Enable aws
vault auth enable aws

# Enable github
vault auth enable github

# Enable LDAP
vault auth enable ldap

# Enable list of auth methods
vault auth list

# Read auth method config
vault read sys/auth/userpass

# Disable auth method
vault auth disable userpass
```

### 7.2 Token Authentication

```bash
# Login with token (default method)
vault login token=<token>

# Login via CLI (uses VAULT_TOKEN)
vault login

# Login with token using env var
export VAULT_TOKEN=<token>

# Verify current auth
vault token lookup
```

### 7.3 Userpass Authentication

```bash
# Create user
vault write auth/userpass/users/admin \
    password="password123" \
    policies="default,admin"

# Create user with TTL
vault write auth/userpass/users/dev-user \
    password="dev123" \
    policies="default" \
    ttl="8h"

# Login with userpass
vault login -method=userpass \
    username=admin \
    password=password123

# Update password
vault write auth/userpass/users/admin/password password="newpassword"

# Delete user
vault delete auth/userpass/users/admin

# List users
vault list auth/userpass/users/
```

### 7.4 AppRole Authentication

```bash
# Create AppRole
vault write auth/approle/role/my-role \
    token_ttl=1h \
    token_max_ttl=24h \
    token_policies=default,app-policy

# Read role ID
vault read auth/approle/role/my-role/role-id

# Generate secret ID
vault write -f auth/approle/role/my-role/secret-id

# Generate with custom metadata
vault write -f auth/approle/role/my-role/secret-id \
    metadata="application=webapp"

# Login with AppRole
vault write auth/approle/login \
    role_id="<role-id>" \
    secret_id="<secret-id>"

# Response includes:
# - client_token
# - accessor
# - policies
# - lease_duration

# Wrap secret ID for secure transmission
vault write -wrap-ttl=60s -f auth/approle/role/my-role/secret-id
```

### 7.5 Kubernetes Authentication

```bash
# Configure Kubernetes auth
vault write auth/kubernetes/config \
    kubernetes_host="https://192.168.99.100:6443" \
    token_reviewer_jwt="$(cat /var/run/secrets/token-reviewer)" \
    disable_local_ca_jwt=true

# Create Kubernetes role
vault write auth/kubernetes/role/my-role \
    bound_service_account_names="vault-sa" \
    bound_service_account_namespaces="default" \
    policies=default,app-policy \
    ttl=1h

# Login with Kubernetes
vault write auth/kubernetes/login \
    role=my-role \
    jwt=<jwt-token-from-service-account>

# Create service account for Vault
kubectl create serviceaccount vault-sa
kubectl create clusterrolebinding vault-rb \
    --clusterrole=system:auth-delegator \
    --serviceaccount=default:vault-sa
```

### 7.6 AWS Authentication

```bash
# Configure AWS auth
vault write auth/aws/config \
    client_ca_arn="arn:aws:iam::123456789012:role/vault-role" \
    detect_ec2_role=true

# Create AWS role
vault write auth/aws/role/my-role \
    bound_iam_principal_arn="arn:aws:iam::123456789012:role/my-app" \
    policies=default,app-policy \
    ttl=1h

# Login with AWS (from EC2 with appropriate role)
vault write auth/aws/login \
    role=my-role \
    pkcs7=<base64-encoded-pkcs7-from-ec2-metadata>

# Login using access key
vault write auth/aws/login \
    role=my-role \
    access_key=<access-key> \
    secret_key=<secret-key> \
    session_token=<session-token>
```

### 7.7 GitHub Authentication

```bash
# Configure GitHub auth
vault write auth/github/config \
    organization="my-org"

# Create GitHub team policy
vault write auth/github/map/teams/my-team \
    value="default,app-policy"

# Login with GitHub token
vault login -method=github \
    token=<github-personal-access-token>

# Vault validates token against GitHub API
```

### 7.8 Entity and Groups

```bash
# Create entity
vault write identity/entity \
    name="app-service" \
    metadata="environment=prod" \
    policies=app-policy

# Create entity alias (link to auth method)
vault write identity/entity-alias \
    name="app-service" \
    canonical_id="<entity_id>" \
    mount_accessor="auth_userpass_<accessor>"

# Create group
vault write identity/group \
    name="platform-team" \
    member_entity_ids="<entity_id_1>,<entity_id_2>" \
    policies=platform-policy

# Create group by name
vault write identity/group \
    name="engineering" \
    group_aliases="name=engineering,canonical_mount=auth/github"

# Add entity to group
vault write identity/group/<group_id>/add-member \
    member_entity_id="<entity_id>"

# Lookup entity
vault read identity/entity/id/<entity_id>
```

---

## 8. Vault Architecture Basics

### 8.1 Environment Variables

```bash
# Set Vault address
export VAULT_ADDR="http://localhost:8200"

# Set Vault token
export VAULT_TOKEN="<token>"

# Set namespace (Vault Enterprise)
export VAULT_NAMESPACE="admin"

# Set CA certificate
export VAULT_CACERT="/path/to/ca.pem"

# Set client certificate
export VAULT_CLIENT_CERT="/path/to/client.pem"

# Verify configuration
vault status
vault version
```

### 8.2 Seal and Unseal

```bash
# Check seal status
vault status

# Output:
# Sealed          false
# Total Shares    5
# Threshold       3

# Seal Vault (manual)
vault operator seal

# After seal:
# - Vault rejects requests
# - All sealed
# - Unsealing required to resume

# Unseal Vault (Shamir)
vault operator unseal

# Enter unseal keys (3 of 5 required)
# Key 1: ...
# Key 2: ...
# Key 3: ...

# Verify unsealed
vault status
# Sealed: false

# Auto-unseal (AWS KMS example)
vault write sys/seal \
    type="awskms" \
    config="..."
```

### 8.3 Storage Backend

```bash
# Integrated Storage (RAFT)
vault operator raft list-peers

vault operator raft add-peer \
    peer-id="vault-2" \
    address="127.0.0.2:8201"

vault operator raft remove-peer \
    peer-id="vault-2"

# Check storage status
vault read sys/storage/raft/configuration

# Backup snapshot
vault operator raft snapshot save backup.snap

# Restore snapshot
vault operator raft snapshot restore backup.snap
```

### 8.4 Audit Devices

```bash
# Enable file audit
vault audit enable file \
    file_path=/var/log/vault/audit.log

# Enable syslog audit
vault audit enable syslog

# Enable socket audit
vault audit enable socket \
    address="tcp://localhost:8200"

# List audit devices
vault audit list

# Disable audit
vault audit disable file
```

### 8.5 Health and Status

```bash
# Check health
curl -s http://localhost:8200/v1/sys/health

# Check leader status
vault read sys/leader

# Check HA status
vault read sys/ha-status

# Check metrics
curl -s http://localhost:8200/v1/sys/metrics

# Health with specific options
vault read sys/health?standbyok=true&sealedcode=200
```

---

## 9. Additional Essential Commands

### 9.1 Lease Commands

```bash
# List leases by prefix
vault list sys/leases/lookup/kv-v2/

# Lookup lease
vault lease lookup <lease_id>

# Renew lease
vault lease renew <lease_id>

# Revoke lease
vault lease revoke <lease_id>

# Revoke all leases with prefix
vault lease revoke -prefix kv-v2/

# Revoke all leases
vault lease revoke -prefix sys/
```

### 9.2 Path Help

```bash
# Get help for any path
vault path-help transit/encrypt/my-key

vault path-help kv-v2/data/my-secret

vault path-help auth/token/create

# Useful for understanding available operations
```

### 9.3 Debug Commands

```bash
# Generate debug archive
vault debug -output=/tmp/vault-debug.tar.gz

# Capture metrics
vault debug -metrics-interval=30s

# Include in debug output:
# - Configuration
# - Logs
# - Metrics
# - State
```

---

## 10. Exam Tips & Cheat Sheet

### 10.1 Common Exam Scenarios

| Scenario | Command |
|----------|---------|
| Create versioned secret | `vault kv put kv-v2/app key="value"` |
| Read version 3 | `vault kv get -version=3 kv-v2/app` |
| Delete version 2 | `vault kv delete -versions=2 kv-v2/app` |
| Undelete version 2 | `vault kv undelete -versions=2 kv-v2/app` |
| Destroy version 2 | `vault kv destroy -versions=2 kv-v2/app` |
| Encrypt with transit | `vault write transit/encrypt/mykey plaintext=$(echo "data" \| base64)` |
| Decrypt with transit | `vault write -field=plaintext transit/decrypt/mykey ciphertext="..." \| base64 -d` |
| Rotate transit key | `vault write -f transit/keys/mykey/rotate` |
| Create orphan token | `vault token create -orphan` |
| Create token with TTL | `vault token create -ttl=1h` |
| Wrap secret | `vault kv get -wrap-ttl=120s kv-v2/secret` |
| Unwrap wrapped token | `vault unwrap` |
| Check token capabilities | `vault token capabilities secret/` |
| Get dynamic DB creds | `vault read database/creds/my-role` |
| Revoke lease | `vault lease revoke <lease_id>` |

### 10.2 KV v1 vs KV v2 Paths

```
KV v1 API:  secret/<key_path>
KV v2 API:  secret/data/<key_path>
            secret/metadata/<key_path>

CLI Commands:
KV v2:      vault kv put secret/data/web-app     (full path with /data/)
            vault kv put secret/web-app          (CLI adds /data/ automatically)
```

### 10.3 Token Types

| Type | Renewal | Use Case |
|------|---------|----------|
| Service | Manual renewal | Long-running services |
| Batch | No renewal | Short-lived, high-scale |
| Periodic | Auto-renewal | Long-running, no manual |
| Orphan | No parent | Independent services |

### 10.4 Transit Ciphertext Format

```
vault:v1:abc123...
 ||  |  |
 ||  |  +-- Base64 ciphertext
 ||  +------ Key version
 |+--------- Version prefix
 +---------- Vault wrapper marker
```

### 10.5 Key Exam Objectives Summary

1. **Authentication**: Userpass, AppRole, Kubernetes, AWS, GitHub, LDAP
2. **Policies**: Path, capabilities, *, sudo, deny
3. **Tokens**: Service/batch, TTL, orphan, accessors, parent-child
4. **Leases**: Lease ID, renew, revoke
5. **Secrets Engines**: KV, Transit, Database, Dynamic vs Static
6. **Encryption**: Transit encrypt/decrypt, rotate, rewrap
7. **Architecture**: Seal/unseal, storage, replication
8. **Deployment**: HCP vs self-managed
9. **Access Management**: Vault Agent, VSO

### 10.6 Important Notes

- **Deny by default**: No policy = no access
- **Root token**: Use only for initial setup/emergencies
- **Service tokens**: Can be renewed until max TTL
- **Batch tokens**: Cannot be renewed
- **KV v1**: No versioning, permanent overwrite
- **KV v2**: Versioning, soft delete, destroy
- **Transit**: Doesn't store data, just encrypts/decrypts
- **Dynamic secrets**: Created on demand, have leases
- **Static secrets**: Stored directly, no automatic rotation
- **Wrapping token**: One-time use, TTL enforced

---

## Quick Reference Commands

```bash
# Setup a dev server
vault server -dev -dev-root-token-id=root

# Common operations
vault status
vault secrets list
vault auth list
vault policy list

# Read info
vault read sys/mounts
vault read sys/health
vault read sys/leader

# Token operations
vault token create -policy=default -ttl=1h
vault token lookup
vault token renew
vault token revoke -self

# KV operations
vault kv put secret/app api_key="key"
vault kv get secret/app
vault kv get -version=2 secret/app
vault kv delete secret/app
vault kv metadata get secret/app

# Transit operations
vault secrets enable transit
vault write -f transit/keys/app
vault write transit/encrypt/app plaintext=$(echo "data" | base64)
vault write transit/decrypt/app ciphertext="..."

# Database operations
vault secrets enable database
vault write database/config/my-db plugin_name=postgresql-database-plugin ...
vault write database/roles/my-role creation_statements=@sql-file.sql ...
vault read database/creds/my-role

# Wrapping
vault kv get -wrap-ttl=60s secret/app
vault unwrap
vault rewrap
```

---

Good luck with your Vault Associate (003) certification exam!