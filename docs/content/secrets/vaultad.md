---
title: "Hashicorp Vault integration with AD and SSH signing"
date: "2021-12-07"
---

## NOTE!

The configurations, descriptions and demo were written on the basis of using Vault with existing infrastructure of TalTech HPC and as such is catered to different requirements: not all is applicaple to your needs and needs some rethinking to fit into the workflows of your use cases. In any case, it should be a good overview of what Vault is capable of, what problems it can resolve, how it can be set up and managed.

## Vault

Vault is an identity-based secrets and encryption management system. A secret is anything that you want to tightly control access to, such as API encryption keys, passwords, or certificates. Vault provides encryption services that are gated by authentication and authorization methods. Using Vault’s UI, CLI, or HTTP API, access to secrets and other sensitive data can be securely stored and managed, tightly controlled (restricted), and auditable.

[Hashicorp Vault documentation](https://www.vaultproject.io/docs/what-is-vault)

### First setup for back-end

Copy `vault.hcl` to `/etc/vault.d/` and start the back-end:

- Manually...

```bash
sudo nohup vault server -config=/etc/vault.d/vault.hcl > /var/log/vault-manual.log &
```

- ...or as a systemd service

```bash
sudo systemctl enable vault.service && sudo systemctl start vault.service
```

Then initialize the host and NOTE DOWN THE GENERATED KEYS:

```bash
vault operator init
```

Vault starts in a [sealed state](https://www.vaultproject.io/docs/concepts/seal), to unseal, use the following command three times:

```bash
vault operator unseal
```

Back-end should now be running and Vault should be unsealed.

### Write policies

Create `hpc-default` policy. Applied to all logins with AD group `HPC Centre`:

```bash
vault policy write hpc-default hpc-default.hcl
```

### [Azure AD authentication method](https://www.vaultproject.io/docs/auth/jwt/oidc_providers#azure-active-directory-aad) setup

NOTE: users with over 200 groups might run into problems. Additionl setup needed to accomodate users with over 200 groups. Check the relevant chapter in Vault official docs [HERE](https://www.vaultproject.io/docs/auth/jwt/oidc_providers#optional-azure-specific-configuration)!

Authenticate as root with the generated root token:

```bash
vault login
```

Enable OIDC auth:

```bash
vault auth enable oidc
```

Configure OIDC for Azure AD with the default role:

```bash
AUTH0_DOMAIN="login.microsoftonline.com/<YOUR-TENANT-ID-HERE>/v2.0"
AUTH0_CLIENT_ID="<YOUR-AZURE-APP-ID-HERE>"
AUTH0_CLIENT_SECRET="<YOUR-AZURE-APP-SECRET-HERE>"
AUTH0_DEFAULT_ROLE="aad"

vault write auth/oidc/config \
   oidc_discovery_url="https://$AUTH0_DOMAIN" \
   oidc_client_id="$AUTH0_CLIENT_ID" \
   oidc_client_secret="$AUTH0_CLIENT_SECRET" \
   default_role="$AUTH0_DEFAULT_ROLE"
```

Configure the default role

```bash
AUTH0_USER_CLAIM="email"
AUTH0_ALLOWED_REDIRECT_URI="http://localhost:8250/oidc/callback,$VAULT_ADDR/ui/vault/auth/oidc/oidc/callback"
AUTH0_HPC_POLICY="default"
AUTH0_TTL="1h"
AUTH0_OIDC_SCOPES="profile"
HPC_AZURE_GROUP_ID="<YOUR-AZURE-APP-ID-HERE>"


vault write auth/oidc/role/aad -<<EOF
{
  "user_claim": "$AUTH0_USER_CLAIM",
  "allowed_redirect_uris": "$AUTH0_ALLOWED_REDIRECT_URI",
  "policies": "$AUTH0_HPC_POLICY",
  "ttl": "$AUTH0_TTL",
  "oidc_scopes": "$AUTH0_OIDC_SCOPES",
  "bound_claims": { "groups": ["$HPC_AZURE_GROUP_ID"] }
}
EOF
```

Link default role and policy for users with AD group `HPC Centre`:

```bash
AUTH0_ACCESSOR=$(vault auth list -format=json | jq -r '."oidc/".accessor')
HPC_VAULT_GROUP_NAME="HPC Centre"
HPC_VAULT_GROUP_POLICY="hpc-default"
HPC_VAULT_GROUP_ID=$(vault write \
   -field=id -format=table \
   identity/group \
   name="$HPC_VAULT_GROUP_NAME" \
   type="external" \
   policies="$HPC_VAULT_GROUP_POLICY")

vault write identity/group-alias \
   name="$HPC_AZURE_GROUP_ID" \
   mount_accessor="$AUTH0_ACCESSOR" \
   canonical_id="$HPC_VAULT_GROUP_ID"
```

### [Key/Value version 1 engine](https://www.vaultproject.io/docs/secrets/kv/kv-v1) setup

The `kv` secrets engine is used to store arbitrary secrets within the configured physical storage for Vault. Writing to a key in the `kv` backend will replace the old value; sub-fields are not merged together.

Enable a version 1 kv for personal secrets:

```bash
vault secrets enable -path="personal" kv
```

According to `hpc-default` policy:

- Every `HPC Centre` group user can store personal secrets that only they can modify and read at the templated path `personal/{{identity.entity.aliases.$AUTH0_ACCESSOR.name}}/*`
- Every `HPC Centre` group user can create write-only secrets to any other users path `personal/*` (Existing values can not be modified/overwritten).

Enable a version 1 kv for general secrets:

```bash
vault secrets enable -path="secret" kv
```

General secrets should follow a defined structure that is agreed upon beforehand. The more granular the paths are, the easier it will be to manage these secrets as the amount of secrets grows. In essence paths should be something like the following example:

```bash
secret/
├── hpc-default/
│   └── base/
│        └── testsecret="Sup3rS3cr3t"
│
├── hpc-sysadmin/
│   └── clusters/
│        ├── amp/
│        ├── grey/
│        └── green/
│
└── hpc-dev/
    └── invenio/
```

### [Userpass authentication method](https://www.vaultproject.io/docs/auth/userpass) setup

The `userpass` auth method allows users to authenticate with Vault using a username and password combination.

Userpasses have to be made manually and can then be linked with other entities, like the one generated by logging in via OIDC Azure AD method.

Enable `userpass` auth method:

```bash
vault auth enable userpass
```

Then create new user with a random password:

```bash
vault write auth/userpass/users/<YOUR-USER-HERE> password=<RANDOM-PASS-HERE>
```

And then link it with the users entity identity manually via the GUI from `Access > Entities > USERS-ENTITY > Add alias` with `Name` field value as the same name as entered in the step before and with `Auth Backend` as `userpass/ (userpass)`.

Then, according to `hpc-default` policy, the user can change their password with:

```bash
vault write auth/userpass/users/<YOUR-USER-HERE> password="<THEIR-NEW-PASS-HERE>"
```

### [Client SSH key signing](https://www.hashicorp.com/blog/managing-ssh-access-at-scale-with-hashicorp-vault) setup

Mount the `ssh-client-signer` secrets engine:

```bash
vault secrets enable -path=ssh-client-signer ssh
```

Configure Vault with a CA for signing client keys using the `/config/ca` endpoint. If you do not have an internal CA, Vault can generate a keypair for you:

```bash
vault write ssh-client-signer/config/ca generate_signing_key=true
```

If you already have a keypair, specify the public and private key parts as part of the payload:

```bash
vault write ssh-client-signer/config/ca \
    private_key="..." \
    public_key="..."
```

#### Host machine(s) setup

Add the public key to all target host's SSH configuration. This process can be manual or automated using a configuration management tool. The public key is accessible via the API and does not require authentication.

Use:

```bash
curl -o /etc/ssh/trusted-user-ca-keys.pem $VAULT_ADDR/v1/ssh-client-signer/public_key
```

Or:

```bash
vault read -field=public_key ssh-client-signer/config/ca > /etc/ssh/trusted-user-ca-keys.pem
```

Add the path where the public key contents are stored to the SSH configuration file at `/etc/ssh/sshd_config` as the `TrustedUserCAKeys` option:

```text
TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
```

Create AuthorizedPrincipalsFile file structure:

```bash
mkdir /etc/ssh/auth_principals/
```

Create principals with users that can authenticate inside them. With this example <VAULT-USER-HERE> can authenticate to `ubuntu@host`:

```bash
sudo echo "<VAULT-USER-HERE>" > ubuntu
```

Add the path where the principals are stored to the SSH configuration file at `/etc/ssh/sshd_config` as the `AuthorizedPrincipalsFile` option:

```bash
AuthorizedPrincipalsFile /etc/ssh/auth_principals/%u
```

It is good practice to also disable password auth via SSH at the configuration file at `/etc/ssh/sshd_config`:

```text
ChallengeResponseAuthentication
noPasswordAuthentication no
```

Restart `sshd` service:

```bash
sudo systemctl restart sshd
```

Then create separate roles for each user to have granular management over each user. NOTE: setting `algorithm_signer` is especially important (Valid values are `ssh-rsa`, `rsa-sha2-256`, and `rsa-sha2-512`), as `ssh-rsa` is the default but now considered insecure. Note that `allowed_users` controls the principals the Vault user is allowed to sign and connect with. If you need to restrict someone's SSH access, just change their roles `allowed_users` field. Example:

```bash
vault write ssh-client-signer/roles/my-role -<<"EOH"
{
  "algorithm_signer": "rsa-sha2-512",
  "allow_user_certificates": true,
  "allowed_users": "*",
  "allowed_extensions": "permit-pty,permit-port-forwarding",
  "default_extensions": [
    {
      "permit-pty": ""
    }
  ],
  "key_type": "ca",
  "default_user": "ubuntu",
  "ttl": "8h"
}
EOH
```

It is beenficial for SSH key signing roles use templating to avoid manual policy creations. At the time of writing `hpc-default.hcl` used `ssh-client-signer/sign/{{identity.entity.aliases.<USERPASS-ACCESSOR-ID-HERE>.name}}` for templating. Which means SSH key signing roles must match `userpass` auth method names (which also have to be created manually).

#### Client side setup

Ask Vault to sign your public key. `valid_principals` field MUST match `ssh-client-signer/sign/<YOUR-ROLE-HERE>` role's `allowed_users`:

```bash
vault write -field=signed_key ssh-client-signer/sign/sample-role \
 public_key=@$HOME/.ssh/alice-key.pub valid_principals=sample > ~/.ssh/alice-signed-key.pub
```

To customize the signing options, use a JSON payload:

```bash
vault write ssh-client-signer/sign/my-role -<<"EOH"
{
  "public_key": "ssh-rsa AAA...",
  "valid_principals": "my-user",
  "key_id": "custom-prefix",
  "extensions": {
    "permit-pty": "",
    "permit-port-forwarding": ""
  }
}
EOH
```

(Optional) View enabled extensions, principals, and metadata of the signed key:

```bash
ssh-keygen -Lf ~/.ssh/signed-cert.pub
```

SSH into the host machine using the signed key. You must supply both the signed public key from Vault and the corresponding private key as authentication to the SSH call:

```bash
ssh -i signed-cert.pub -i ~/.ssh/id_rsa username@host
```

### Host SSH key signing setup (not tested as of writing)

Mount the `ssh-host-signer` secrets engine:

```bash
vault secrets enable -path=ssh-host-signer ssh
```

Configure Vault with a CA for signing client keys using the `/config/ca` endpoint. If you do not have an internal CA, Vault can generate a keypair for you:

```bash
vault write ssh-host-signer/config/ca generate_signing_key=true
```

If you already have a keypair, specify the public and private key parts as part of the payload:

```bash
vault write ssh-host-signer/config/ca \
    private_key="..." \
    public_key="..."
```

Extend host key certificate TTLs:

```bash
vault secrets tune -max-lease-ttl=87600h ssh-host-signer
```

Create a role for signing host keys. Be sure to fill in the list of allowed domains:

```bash
vault write ssh-host-signer/roles/hostrole \
    key_type=ca \
    ttl=87600h \
    allow_host_certificates=true \
    allowed_domains="localdomain,example.com" \
    allow_subdomains=true
```

Sign the host's SSH public key:

```bash
vault write ssh-host-signer/sign/hostrole \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub
```

Set the resulting signed certificate as `HostCertificate` in the SSH configuration on the host machine:

```bash
vault write -field=signed_key ssh-host-signer/sign/hostrole \
    cert_type=host \
    public_key=@/etc/ssh/ssh_host_rsa_key.pub > /etc/ssh/ssh_host_rsa_key-cert.pub
```

Set permissions on the certificate to be `0640`:

```bash
chmod 0640 /etc/ssh/ssh_host_rsa_key-cert.pub
```

Add host key and host certificate to the SSH configuration file at `/etc/ssh/sshd_config`:

```text
# For host keys
HostKey /etc/ssh/ssh_host_rsa_key
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
```

Restart `sshd` service:

```bash
sudo systemctl restart sshd
```

#### Client-Side Host Verification

Retrieve the host signing CA public key to validate the host signature of target machines.

Use:

```bash
curl $VAULT_ADDR/v1/ssh-host-signer/public_key
```

Or:

```bash
vault read -field=public_key ssh-host-signer/config/ca
```

### [Backup](https://learn.hashicorp.com/tutorials/vault/raft-storage?in=vault/raft#data-snapshots-for-recovery) setup

This assumes that Raft is used as the storage back-end.

Create a backup:

- Manually:

```bash
vault operator raft snapshot save demo.snapshot
```

- [Automatically with schedule](https://learn.hashicorp.com/tutorials/vault/sop-backup#automated-backup-procedures) via CLI:

```bash
vault write sys/storage/raft/snapshot-auto/config/daily interval="24h" retain=5 path_prefix="raft-backup" storage_type="local" local_max_space=1073741824
```

Automatically with schedule with:

```bash
vault read sys/storage/raft/snapshot-auto/config/daily
```

Restore with:

```bash
vault operator raft snapshot restore demo.snapshot
```

### Other secret engines and use cases

Vault provides more secret engines and use cases that may be of use but were not covered in this test/demo.

#### Using Key/Value engine as a way to track and renew SSL certs

Certificates get issued after Let’s Encrypt validates that users control the domain names in those certificates using the ACME API and “challenges”. The most popular ones are the HTTP-01 and the DNS-01. The first requires users to get a particular file and serve it via HTTP or HTTPS, so that the Let’s Encrypt servers are able to retrieve it. The latter uses DNS records respectively, so that Let’s Encrypt can validate the domain ownership via queries. There are already many clients which ease both of those processes with EFF’s Certbot being the most prominent one.

Certbot supports certificate creation and renewal using both challenge types. For dealing with multiple domain names from one server, HTTP-01 challenges seem to be cumbersome: Certbot must serve some traffic on ports 80 and 443 for the Let’s Encrypt servers to validate the domains. DNS-01 challenges are better on this perspective, but still this is not to be considered cloud-ready for two reasons:

- The certificate state is stored locally on the server
- The renewal process depends on a running cronjob of the same server

To tackle with the first point, could still use Certbot, but store certificates, tokens etc. in Vault.

#### Vault engines not covered in test

[Database engine](https://www.vaultproject.io/docs/secrets/databases)

The database secrets engine generates database credentials dynamically based on configured roles. It works with a number of different databases through a plugin interface. There are a number of built-in database types, and an exposed framework for running custom database types for extendability. This means that **services that need to access a database no longer need to hardcode credentials**: they can request them from Vault, and use Vault's leasing mechanism to more easily roll keys. These are referred to as "dynamic roles" or "dynamic secrets".

Since every service is accessing the database with unique credentials, it makes auditing much easier when questionable data access is discovered. You can track it down to the specific instance of a service based on the SQL username.

[PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki)

The PKI secrets engine generates dynamic X.509 certificates. With this secrets engine, services can get certificates without going through the usual manual process of generating a private key and CSR, submitting to a CA, and waiting for a verification and signing process to complete. Vault's built-in authentication and authorization mechanisms provide the verification functionality.

By keeping TTLs relatively short, revocations are less likely to be needed, keeping CRLs short and helping the secrets engine scale to large workloads. This in turn allows each instance of a running application to have a unique certificate, eliminating sharing and the accompanying pain of revocation and rollover.

In addition, by allowing revocation to mostly be forgone, this secrets engine allows for ephemeral certificates. Certificates can be fetched and stored in memory upon application startup and discarded upon shutdown, without ever being written to disk.

[Transit Secrets Engine](https://www.vaultproject.io/docs/secrets/transit)

The transit secrets engine handles cryptographic functions on data in-transit. Vault doesn't store the data sent to the secrets engine. It can also be viewed as "cryptography as a service" or "encryption as a service". The transit secrets engine can also sign and verify data; generate hashes and HMACs of data; and act as a source of random bytes.

The primary use case for transit is to encrypt data from applications while still storing that encrypted data in some primary data store. This relieves the burden of proper encryption/decryption from application developers and pushes the burden onto the operators of Vault.

Key derivation is supported, which allows the same key to be used for multiple purposes by deriving a new key based on a user-supplied context value. In this mode, convergent encryption can optionally be supported, which allows the same input values to produce the same ciphertext.

Datakey generation allows processes to request a high-entropy key of a given bit length be returned to them, encrypted with the named key. Normally this will also return the key in plaintext to allow for immediate use, but this can be disabled to accommodate auditing requirements.

### [Security/Threat model](https://www.vaultproject.io/docs/internals/security#security-model)

HPC specific risks:

- Vault traffic might be eavesdropped
  - Solution: Disable unencrypted HTTP comms, only use TLS encrypted traffic.
- User with signed SSH key might insert their own key to authorized keys list.
  - Solution: Restrict machine user permissions.
  - Solution: Schedule automatic SSH configuration deployment that clears dirs and inserts up-to-date configs to machines.
- Signed SSH key most likely TTL left after revoking SSH signing permissions.
  - Solution: Admin generates new CA key.
- Authenticated user might have TTL left after revoking auth permissions.
  - Solution: Disable/delete auth entity.

## HPC Vault

Vault is an identity-based secrets and encryption management system. A secret is anything that you want to tightly control access to, such as API encryption keys, passwords, or certificates. Vault provides encryption services that are gated by authentication and authorization methods. Using Vault’s UI, CLI, or HTTP API, access to secrets and other sensitive data can be securely stored and managed, tightly controlled (restricted), and auditable.

[Hashicorp Vault documentation](https://www.vaultproject.io/docs/what-is-vault)

HPC demo Vault is accessible via https://vault.jamfox.dev:8200

To communicate with Vault you can use:

- Webapp GUI by going to https://vault.jamfox.dev:8200
- Via [API](https://www.vaultproject.io/api-docs).
- Via CLI after installing Vault client on your machine.

## Self-service demo walkthrough

### Azure AD auth

The following will only work if you have the `HPC Centre` group associated with your TalTech Uni-ID account. If a user is part of the `HPC Centre` group then they will automatically be assigned the `hpc-default` policy needed for doing any of the following steps.

Via web browser:

- Go to https://vault.jamfox.dev:8200 on your browser, click on `oidc` and then click `Sign in with OIDC Provider`.

Via CLI:

- Use the command `vault login -method=oidc` then a browser pop-up should appear.

### Userpass auth

Azure auth is good for checking if user is part of required groups and linking those groups with Vault policies, but userpass auth makes it easier to automate Vault CLI usage.

After authenticating with Azure AD ask for administrator to create an userpass alias for you.

Then set your password for userpass via CLI:

```bash
vault write auth/userpass/users/<YOUR-USER-PROVIDED-BY-ADMIN-HERE> password="<YOUR-NEW-PASS-HERE>"
```

Then log in with it via:

- web UI
- CLI:

```bash
vault login -method=userpass \
    username=<YOUR-USER> \
    password=<YOUR-PASS>
```

### Key/Value secrets

Key/Value secrets are a key part of using Vault (pun intended). The `kv` secrets engine is used to store arbitrary secrets within the configured physical storage for Vault. Writing to a key in the `kv` backend will replace the old value; sub-fields are not merged together.

Current proposal is to use 2 Key/Value engines. One named `personal` for personal secrets and the other named `secret` for general secrets.

According to `hpc-default` policy:

- Every `HPC Centre` group user can store personal secrets that only they can modify and read at the templated path `personal/{{identity.entity.aliases.<AUTH0-ACCESSOR-HERE>.name}}/*` where `{{identity.entity.aliases.<AUTH0-ACCESSOR-HERE>.name}}` is the associated TalTech Uni-ID email.
- Every `HPC Centre` group user can create write-only secrets to any other users path `personal/*` (Existing values can not be modified/overwritten).

General secrets should follow a defined structure that is agreed upon beforehand. The more granular the paths are, the easier it will be to manage these secrets as the amount of secrets grows. In essence paths should be something like the following example (bad barebones example, but hopefully it gets the essence across well enough):

```bash
secret/
├── hpc-default/
│   └── base/
│        └── testsecret="Sup3rS3cr3t"
│
├── hpc-sysadmin/
│   └── clusters/
│        ├── amp/
│        ├── grey/
│        └── green/
│
└── hpc-dev/
    └── invenio/
```

The easiest way to store and read secrets is to use the web UI. So navigate to https://vault.jamfox.dev:8200 and under `Secrets` click on `secret` or `personal` and see what you can find, create some secrets, update them, try to send someone a personal secret.

### SSH access using vault

SSH roles must match userpass name that was created for you for the permissions to link properly. So, after authenticating with Azure AD and after asking administrator to create an userpass alias for you, ask the administrator to create an SSH role for you.

Then ask Vault to sign your public key. `valid_principals` field MUST match `ssh-client-signer/sign/<YOUR-ROLE-HERE>` role's `allowed_users` that admin has set for you:

```bash
vault write -field=signed_key ssh-client-signer/sign/<YOUR-USERPASS-NAME> \
 public_key=@$HOME/.ssh/<YOUR-KEY>.pub valid_principals=<YOUR-PRINCIPAL-HERE> > ~/.ssh/<YOUR-KEY>-signed.pub
```

(Optional) View enabled extensions, principals, and metadata of the signed key:

```bash
ssh-keygen -Lf ~/.ssh/signed-cert.pub
```

SSH into the host machine using the signed key. You must supply both the signed public key from Vault and the corresponding private key as authentication to the SSH call:

```bash
ssh -i <YOUR-KEY>-signed.pub -i ~/.ssh/<YOUR-KEY> username@host
```

For the purposes of the demo, ask administrator to add your principal to training headnode. Then try connecting to training headnode:

```bash
ssh -i <YOUR-KEY>-signed.pub -i ~/.ssh/<YOUR-KEY> centos@193.40.156.61
```
