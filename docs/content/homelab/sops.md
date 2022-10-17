---
title: "SOPS"
---

[SOPS](https://github.com/mozilla/sops), short for Secrets OPerationS, is an open-source text file editor that encrypts/decrypts files automagically.

Text editors and encryption tools already exist, however the ease of use is very low when using them separately. Emphasis with SOPS is on that the text editor and encryption features are packaged in one automated tool.

SOPS's ability to encrypt whole files as well as parts of structured content like variables in yaml makes it powerful for use in Ansible, Kubernetes, etc.

## Installing

Binaries and packages of the latest stable release are available at [SOPS GitHub](https://github.com/mozilla/sops/releases).

## Setting up PGP keys

Install GnuPG GPG CLI tool:

```bash
apt install gnupg
```

Create the keys:

```bash
gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: <YOUR COMMENT>
Name-Real: <YOUR KEY NAME>
EOF
```

List keys:

```bash
gpg --list-keys
```

Export keys to file:

```bash
gpg --export -a <YOUR KEY NAME> > $HOME/public.key
gpg --export-secret-key -a <YOUR KEY NAME> > $HOME/private.key
```

Import keys:

```bash
gpg --import $HOME/public.key
gpg --import $HOME/private.key
```

To configure SOPS paste the public key fingerprint to `$HOME/.sops.yaml` (invalid sample value used here):

```yaml
creation_rules:
    - pgp: >-
        B32GJd94DA0891D930LG3F35B432D146C9C4BC
```

## Usage

Edit file and encrypt automatically:

```bash
sops secret-txt-file.txt
```

`cat` the file to see that it's contents have been encrypted and converted into a json.

Encrypting the full content of a text file is powerful, but if the file contains structured data, for example:

- *.yaml
- *.json
- *.ini
- *.env

Then SOPS encrypts only the content you edited not the whole file:

```bash
sops secret-yml-file.yaml
```

The follwing:

```yaml
username: user1
password: hunter2
```

Will become:

```yaml
username: user1
password: ENC[AES256_GCM,data:z2soJW==,iv:IZ841YNdsr4olKw3A304IFT/OgWSEqkrO29s=,tag:bRJHVasldDFfgOjQGkEi==,type:str]
```
