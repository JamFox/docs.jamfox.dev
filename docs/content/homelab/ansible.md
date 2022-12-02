---
title: "Ansible"
---

!!! info
    [Ansible Homepage](https://www.ansible.com/) |
    [Ansible Documentation](https://docs.ansible.com/) |
    [jamlab-ansible](https://github.com/JamFox/jamlab-ansible) |
    [Jeff Geerling's Ansible Guide](https://www.jeffgeerling.com/blog/2020/ansible-101-jeff-geerling-youtube-streaming-series) |
    [Fast Ansible Guide](https://github.com/omerbsezer/Fast-Ansible)

[Ansible](https://docs.ansible.com/ansible/latest/index.html) is a software tool that provides simple but powerful automation for cross-platform computer support. It is primarily intended for IT professionals, who use it for application deployment, updates on workstations and servers, cloud provisioning, configuration management, intra-service orchestration, and nearly anything a systems administrator does on a weekly or daily basis. Ansible doesn't depend on agent software and has no additional security infrastructure, so it's easy to deploy.

For the best guide for deep diving into using Ansible check out [Jeff Geerling's Ansible Guide](https://www.jeffgeerling.com/blog/2020/ansible-101-jeff-geerling-youtube-streaming-series).

Ansible was the obvious choice for me as I had quite a lot of experience with it. For configuration management it made sense to go with something simple to ease bootstrapping and favoring mutability for fastest development. Running a whole platform like Puppet did not make sense because of bootstrapping and resource overhead. Ansible is simple to write, understand and manage if written well from the get-go.

Also knowing Ansible I knew how slow it can be. There's two ways of solving this: using push mode with a central management (with homebrew solutions or AWX/Ansible Tower) with parallel playbook execution for each host OR pull mode where each host essentially configures itself. Running AWX/Ansible Tower has the same problem of bootstrapping and resource overhead. Homebrew parallel push system spikes the central management resource usage when executed and requires you to be on two hosts (central management host and the host being configured) when developing. It is quite evident that pull mode is the more scalable, resource efficient and easier for swift changes so I went with that.

I settled on the following requirements:

- Easy to bootstrap (i.e. couple of commands excluding secrets)
- Scalable (execution time does not depend on the number of hosts)
- Simple to modify and manage (DRY monorepo for all hosts)

The solution was [jamlab-ansible](https://github.com/JamFox/jamlab-ansible): Homelab bootstrap and pull-mode configuration management with Ansible and bash. Most of it is "inspired" by a similar system that we used at CERN.

## Ansible Best Practices

### Idempotency

The most important thing about using Ansible is that all tasks should be idempotent. It means that each time any task is run, the result of it should be the same regardless of any state on the machine it is run on. For example if you want to install some package on a host with ansible and use the ansible.builtin.shell module for it with some command. Maybe it will succeed the first time but give an error when the package is already installed.

Instead of ansible.builtin.shell module we should use purpose built Ansible modules if they exist since they will make sure that the result is idempotent.
However you can make shell tasks idempotent as well with some workarounds. For example consider the following very common trick of registering outputs from tasks:

```yaml
# First we check if a directory for CNI exists.
- name: Check if cni exists
ansible.builtin.stat:
    path: /opt/cni/bin/bridge
register: r_cni # Then we register the output of this task in a variable called "r_cni" (using r_ prefix is an old convention)

# Check if newer CNI exists IF the directory in the last task did exist, check "when" key at the bottom of this task
- name: Check if newer cni exists 
ansible.builtin.shell: |
    latest_tag=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r ".tag_name")
    current_ver=$(/opt/cni/bin/bridge 2>&1 | cut -d " " -f 4)
    case "$current_ver" in ${latest_tag} ) echo "latest";; *) echo "outdated";; esac
register: r_cni_ver # We register the output of our commands which in this case is either "lastest" or "outdated" we will use this for handling the cases in the next task
when: r_cni.stat.exists # We only run this task if the output of the last task says that the directory did exist

# Get the latest CNI if the output of the last task was not "latest", check "when" key at the bottom of this task
- name: Get latest cni
ansible.builtin.shell: |
    latest_tag=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r ".tag_name")
    latest_url=https://github.com/containernetworking/plugins/releases/download/${latest_tag}/cni-plugins-linux-amd64-${latest_tag}.tgz
    wget -P /tmp $latest_url
    mkdir -p /opt/cni/bin
    tar -C /opt/cni/bin -xzf /tmp/"${latest_url##*/}"
    rm /tmp/"${latest_url##*/}"
when: not r_cni.stat.exists or r_cni_ver.stdout != "latest" # We run this task if CNI directory does not exist or when the output of the last task was not "latest"
```

### Readability

The second most important thing about using Ansible is always being explicit. For example when using modules, it is better to write "ansible.builtin.shell" instead of "shell". That is because external modules and community modules can also be used, but it should be obvious which module is used.

Also it should be immediately obvious where variables come from and what is the variable override precedence. This why it is not native behavior in Ansible to combine dicts and lists from different "variables" or "defaults" files. Instead the variables will follow a precedence and overwrite the one before it. Usually this follows the pattern of (weakest to strongest precedence): global variables, group variables, host variables. So a list from global variables will be overwritten if a list with same name exists in host variables for example.

## Jamlab Ansible Architecture

And as per [Ansible's own best practices](https://www.ansible.com/blog/ansible-best-practices-essentials): complexity kills productivity. And I think that a typical ansible monorepo is a bit too complex and usually it is not immediately obvious what goes where.

A typical ansible management repository loops something like the examples from the [old best practices doc of Ansible](https://docs.ansible.com/ansible/2.3/playbooks_best_practices.html):

```bash
production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
   group1                 # here we assign variables to particular groups
   group2                 # ""
host_vars/
   hostname1              # if systems need specific variables, put them here
   hostname2              # ""

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies
        library/          # roles can also include custom modules
        module_utils/     # roles can also include custom module_utils
        lookup_plugins/   # or other types of plugins, like lookup in this case

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""
```

In this structure, each root playbook including the master playbook (`site.yml` in this case) is defined in the project root directory and imports roles from `roles/`, variables from `group_vars/` and `host_vars/`. Then the master playbook runs all the other playbooks that define which roles are run on which hosts or host groups. This introduces a problem where a breaking change in one role will halt the whole run. Also, even with well organized root playbooks, it is never immediately obvious which roles are defined for which root playbooks especially if using hosts in multiple groups or child/parent groups. Furthermore, the root playbooks, `group_vars/` and `host_vars/` are in separate directories which is not a huge deal, but this does require one to verify that root playbooks, variables and roles match when planning changes. This requires extra time of getting familiar with what-goes-where especially when doing changes after a long time. For larger projects usually the roles are managed in and imported from separate repositories. It is a great approach, especially for running tests on the roles. However this increases the time of understanding what-goes-where.

These are small nitpicks and for most use cases following the standard structure works well, but for maximum simplicity I grew very fond of a system for pull mode Ansible we used at CERN. An example structure for this system looks something like this:

```bash
ansible.cfg
hosts                       # inventory file

bin/                        # binaries
    bootstrap.sh            # script for setting up host for the first time
    run-playbooks.sh        # script for running relevant playbooks locally on host

playbooks/                  # "root" playbook directory
    group_base/             # ""
        local.yml           # here we define roles for a particular group
        group_vars/         # ""
            all.yml         # here we assign variables to a particular group
    host_basenode/          # here we define roles for a particular host
        local.yml           # define roles for a particular host
        host_vars/          # ""
            basenode.yml    # here we assign variables to a particular host
    function_test/          # ""
        local.yml           # ""

roles/                      # roles directory
    pre/                    # role name 
        defaults/           # ""
            main.yml        # <-- default lower priority variables for this role
        files/              # ""
            file.txt        # <-- files
        tasks/              # ""
            main.yml        # <-- tasks to run for the role
        templates/          # ""
            template.txt.j2 # <-- files for use with the template resource
        vars/               # ""
            main.yml        # <-- variables associated with this role
```

With this system root playbooks are separated into directories with their own variables and are not run from a single master playbook thus each play can run regardless of whether there are errors in other playbooks. Each playbook only defines which roles to run on the host group and nothing else, for example:

```yaml
- name: PLAYBOOK FOR GROUP 'GGG'
  hosts: ggg

  roles:

  - { role: pre, tags: [ pre ], when: not (disabled_roles.pre | default(false)) }

  - { role: rrr, tags: [ rrr ], when: not (disabled_roles.rrr | default(false)) }

  - { role: post, tags: [ post ], when: not (disabled_roles.post | default(false)) }
```

This and it's accompanying variables file make it simple to understand at a glance which roles are run and where the group variables are defined since they are all together in one directory.

Since the playbooks are separated and this system is used in pull mode, a script is needed to figure out which playbook to run, this is why we have the `bin` directory that has the mentioned script inside.

For maximum simplicity of maintaining this script and management of the playbooks and roles it should be enforced that each host is only part of ONE group. This will ensure that it will always be immediately obvious which playbooks are run for what host when looking at the inventory file.

Thus the logic of the script should be to run a maximum of 2 playbooks for a host: one host playbook and one host group playbook if any of them exist.

### Detailed usage

Here's a few more chapters detailing more specific usage of this system and Ansible in general.

#### Secrets

To use secret variables and files with sensitive content [Ansible Vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) can be used. This requires the manual step of setting up a password file and setting it in `ansible.cfg` since you wouldn't want to push the password to a repository:

```bash
[defaults]
vault_password_file = <PATH TO YOUR VAULT PASS>
```

Then you can set secret variables by encrypting strings:

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

You may also encrypt files with:

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

#### Global variables and special roles

There can be two special roles at the beginning and at the end of the playbook. For example `pre` and `post`.

They are used to replace the list of common roles to execute before and after specific ones. They can also be used to set "global" variables.

#### Variable precedence

Variable precedence is as follows (from the weakest to the strongest):

1. role defaults (`rrr/defaults/main.yml`)
2. group vars (`playbooks/ppp/group_vars/all.yml`)
3. host vars (`playbooks/ppp/host_vars/hhh.yml`)
4. ansible argument (`ansible-playbook --extra-vars "my_var=my_value" ...`)

#### Combine group and host vars

After the announcement of deprecating `hash_behaviour=merge` option in Ansible it is no longer possible to conveniently combine dictionaries with same names in role, group and host variables.

When merging dictionaries the following convention should be followed:

For role defaults use the regular variable name `exampledict` in `rrr/defaults/main.yml`:

```yml
exampledict:
    - name: var1
```

For group defaults use the `group_` prefix with variable name `exampledict` in `playbooks/ppp/group_vars/all.yml`:

```yml
group_exampledict:
    - name: var2
```

For host defaults use the `host_` prefix with variable name `exampledict` in `playbooks/ppp/host_vars/hhh.yml`:

```yml
host_exampledict:
    - name: var3
```

Combine dictionaries in role tasks `rrr/tasks/main.yml`:

```yml
- name: Combine role and group vars
  set_fact:
    packages: "{{ packages + group_exampledict }}"
  when: group_exampledict is defined
```

```yml
- name: Combine host and group vars
  set_fact:
    packages: "{{ packages + host_exampledict }}"
  when: host_exampledict is defined
```
