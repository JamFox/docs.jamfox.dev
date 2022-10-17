---
title: "Ansible Vault"
---

[Ansible Vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) is a feature that allows users to encrypt values and data structures within Ansible projects. This provides the ability to secure any sensitive data that is necessary to successfully run Ansible plays but should not be publicly visible, like passwords or private keys. Ansible automatically decrypts vault-encrypted content at runtime when the key is provided.

This requires the manual step of setting up a password file and setting it's path (which should not be in the repository) in `ansible.cfg`.

Using Anisble Vault means that managing secrets becomes as easy as managing the Ansible Vault password file and all other secrets can be set up automatically by running the playbooks.

## Usage

```bash
[defaults]
vault_password_file = <PATH TO YOUR VAULT PASS>
```

Secret variables can be set by encrypting strings:

```bash
ansible-vault encrypt_string password123 
```

And pasting the output in place of a variable:

```yaml
my_password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    66386439653236336462626566653063336164663966303231363934653561363964363833
    3136626431626536303530376336343832656537303632313433360a626438346336353331
```

Encrypt files with:

```bash
ansible-vault encrypt encrypt_me.txt
```

View encrypted files with:

```bash
ansible-vault view encrypt_me.txt
```

Edit encrypted files with:

```bash
ansible-vault edit encrypt_me.txt
```

Decrypt encrypted files with:

```bash
ansible-vault decrypt encrypt_me.txt
```
