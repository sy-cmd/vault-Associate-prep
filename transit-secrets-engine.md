# Transit Secrets Engine

Transit is Vault's **encryption-as-a-service** engine. It encrypts and decrypts data but **never stores it** — your application handles storage. Vault just handles the cryptographic operations.

## What Transit Does (and Does Not Do)

| Does | Does NOT |
|------|----------|
| Encrypt/decrypt data | Store the plaintext |
| Sign and verify data | Replace your database |
| Generate HMACs | Store any application data |
| Generate random bytes | Manage TLS certificates (that's PKI) |
| Generate data keys (envelope encryption) | |

---

## Key Concepts for the Exam

### 1. Key Rotation — The Most Important Concept

When you rotate a Transit key, Vault creates a **new key version**. Old versions are **retained**.

```
Before rotation:   key version 1 only
After 1 rotation:  key versions 1, 2  (latest = 2)
After 2 rotations: key versions 1, 2, 3  (latest = 3)
```

**Critical exam fact:** Rotating a key does NOT break old ciphertext.

- Old ciphertext (e.g. `vault:v1:abc...`) can still be decrypted because Vault keeps all old key versions.
- The ciphertext prefix tells Vault which version was used: `vault:v1:...`, `vault:v2:...`
- New encryptions automatically use the latest key version.

```bash
# Rotate the key
vault write -f transit/keys/orders/rotate

# New encryptions now produce vault:v2:...
vault write transit/encrypt/orders plaintext=$(base64 <<< "hello")

# Old vault:v1:... ciphertext still decrypts fine
vault write transit/decrypt/orders ciphertext="vault:v1:abc123..."
```

---

### 2. Rewrap — Re-encrypt Without Seeing Plaintext

`rewrap` takes old ciphertext and re-encrypts it under the **latest key version** without ever exposing the plaintext to the caller. This is how you migrate old encrypted data after a rotation.

```bash
vault write transit/rewrap/orders \
    ciphertext="vault:v1:abc123..."

# Output: new ciphertext under vault:v2:...
```

**Exam scenario:** A database has millions of rows encrypted with an old key version. After rotation, to migrate them: call `transit/rewrap/orders` for each record. Do NOT use `transit/encrypt` (that would require sending plaintext through Vault again).

---

### 3. Datakey — Envelope Encryption

A `datakey` lets your application encrypt large amounts of data locally without sending all that data through Vault. Vault generates a fresh AES key and gives it to you in two forms:

- **Plaintext** — your app uses this to encrypt data locally, then discards it
- **Ciphertext** — you store this alongside your encrypted data; only Vault can decrypt it back to the plaintext key

```bash
vault write transit/datakey/plaintext/orders \
    context=$(base64 <<< "app-context")

# Returns:
# plaintext  (base64 AES key — use to encrypt, then discard)
# ciphertext (store this; used to recover the key later)
```

**Exam fact:** Datakey returns a new AES key in **both plaintext and ciphertext form**. It does not return a JWT, HMAC, or the Transit key material itself.

---

### 4. min_decryption_version — Retiring Old Key Versions

By default all key versions are kept. To force retirement of old versions (so old ciphertext can no longer be decrypted):

```bash
vault write transit/keys/orders/config \
    min_decryption_version=3
```

After this, any ciphertext encrypted with v1 or v2 will fail to decrypt. Use this after you have confirmed all data has been rewrapped to the latest version.

---

### 5. Auto Rotation

```bash
# Rotate every 24 hours automatically
vault write transit/keys/orders/config auto_rotate_period=24h

# Read key info to confirm
vault read transit/keys/orders
```

---

## Setup and Core Commands

```bash
# Enable the engine
vault secrets enable transit

# Enable at a custom path
vault secrets enable -path=encryption transit

# Create a named encryption key ring
vault write -f transit/keys/orders

# Read key metadata (shows versions, rotation config)
vault read transit/keys/orders
```

---

## Encrypt and Decrypt

Plaintext **must** be base64-encoded before sending to Transit.

```bash
# Encrypt
vault write transit/encrypt/orders \
    plaintext=$(base64 <<< "4111 1111 1111 1111")
# Returns: ciphertext = vault:v1:abc123...

# Decrypt
vault write transit/decrypt/orders \
    ciphertext="vault:v1:abc123..."
# Returns: plaintext in base64

# Decode the base64 plaintext
base64 --decode <<< "NDExMSAxMTExIDExMTEgMTExMQo="
```

---

## Policy Requirements

```bash
vault policy write app-orders - <<EOF
path "transit/encrypt/orders" {
  capabilities = ["update"]
}
path "transit/decrypt/orders" {
  capabilities = ["update"]
}
EOF
```

Note: encrypt and decrypt both require the `update` capability, not `read`.

---

## Exam Cheat Sheet

| Scenario | Command |
|----------|---------|
| Rotate key | `vault write -f transit/keys/orders/rotate` |
| Re-encrypt old ciphertext without seeing plaintext | `vault write transit/rewrap/orders ciphertext=<old_ct>` |
| Get an AES key for local encryption | `vault write transit/datakey/plaintext/orders` |
| Retire old key versions | `vault write transit/keys/orders/config min_decryption_version=3` |
| Auto-rotate every N hours | `vault write transit/keys/orders/config auto_rotate_period=Nh` |
| Read key version info | `vault read transit/keys/orders` |

---

## Common Exam Traps

**Trap 1:** "After rotating a key, old ciphertext can no longer be decrypted."
→ **FALSE.** Old versions are retained. Old ciphertext decrypts fine until you set `min_decryption_version`.

**Trap 2:** "To migrate data after rotation, use `transit/encrypt` again."
→ **WRONG.** Use `transit/rewrap` — it re-encrypts without exposing plaintext.

**Trap 3:** "Datakey returns just the plaintext key."
→ **WRONG.** It returns the key in **both** plaintext AND ciphertext form.

**Trap 4:** "`vault token create -root` regenerates the root token."
→ **WRONG.** Use `vault operator generate-root`.
