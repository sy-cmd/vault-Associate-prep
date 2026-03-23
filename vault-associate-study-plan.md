# HashiCorp Vault Associate (003) - 2-Week Study Plan

## Exam Details
- **Exam Name:** HashiCorp Certified: Vault Associate (003)
- **Version:** Vault 1.16
- **Questions:** 60 multiple-choice questions
- **Duration:** 60 minutes
- **Pass Score:** 70%
- **Cost:** $70 USD
- **Format:** Online, proctored

---

## Week 1: Core Topics Review

### Day 1-2: Authentication Methods
- AppRole pull authentication
- Userpass, LDAP, Kubernetes auth
- Token auth (system vs human)
- Choosing auth method based on use case
- **Reference:** HashiCorp Vault Authentication docs

### Day 3: Policies
- Policy syntax and capabilities
- Path matching (glob, exact)
- sudo vs default policies
- Least privilege principles
- **Reference:** Vault Policies tutorial

### Day 4: Tokens & Leases
- Token types (service, batch, periodic)
- TTL, renewal, orphan tokens
- Token revocation and invalidation
- Lease ID, renew, revoke operations
- **Reference:** Tokens docs, Lease management

### Day 5: KV Secrets Engine
- KV v1 vs v2 differences
- Versioning, soft delete, destroy
- Metadata and secret versioning
- **Reference:** KV Secrets Engine tutorial

### Day 6-7: Hands-On Practice
- Complete HashiCorp Vault Getting Started labs
- Practice with UI, CLI, and API
- Build a local demo environment

---

## Week 2: Advanced Topics + Mock Exams

### Day 1-2: Dynamic Secrets
- Database secrets engine
- AWS/Azure dynamic secrets
- Lease lifecycle for dynamic secrets
- **Reference:** Secrets as a Service: Dynamic Secrets

### Day 3: Transit Engine
- Encryption as a service
- Encrypt/decrypt operations
- Key rotation and rewrapping
- **Reference:** Transit Secrets Engine tutorial

### Day 4: Vault Architecture
- Seal/unseal process
- Storage backends (raft, Consul, etc.)
- High availability
- Integrated storage
- **Reference:** Vault Architecture docs

### Day 5: Audit & Security
- Audit logs (file, syslog)
- Response wrapping
- Token boundaries

### Day 6-7: Practice Exams & Review
- Take practice exams
- Review weak areas
- Focus on exam objectives mapping

---

## Priority Topics (High to Low)

1. **Authentication vs Authorization** - Know the difference and how they work together
2. **Policy syntax and path matching** - Be able to read and write policies
3. **KV v2 features** - Versions, soft delete, destroy, metadata
4. **Token lifecycle** - Creation, renewal, revocation, orphan tokens
5. **Transit engine** - Encryption, rotation, rewrapping
6. **Lease management** - TTL, renew, revoke
7. **Dynamic secrets** - How they work with databases and cloud providers
8. **Vault architecture** - Seal/unseal, storage backends, HA

---

## Key Resources

### Official
- [Vault Associate Learning Path](https://developer.hashicorp.com/vault/tutorials/associate-cert-003/associate-study-003)
- [Review Guide - Exam Objectives](https://developer.hashicorp.com/vault/tutorials/associate-cert/associate-review)
- [Sample Questions](https://developer.hashicorp.com/vault/tutorials/associate-cert/associate-questions)

### Practice
- HashiCorp Learn (free tutorials)
- FlashGenius practice tests
- SkillCertPro practice exams

---

## Exam Tips

- Read questions carefully - look for keywords like "NOT", "ALWAYS", "LEAST"
- Understand when to use open source vs enterprise features
- Know the difference between authentication (who) and authorization (what)
- Be familiar with all major secret engines: KV, Transit, Database, AWS, Azure
- Practice with the Vault CLI - many questions assume CLI knowledge

---

## Quick Reference Commands

```bash
# Enable a secret engine
vault secrets enable -path=secret kv

# Write a secret
vault kv put secret/myapp key1=value1

# Read a secret
vault kv get secret/myapp

# Enable auth method
vault auth enable approle

# Create a policy
vault policy write mypolicy policy.hcl

# Check token info
vault token lookup
```