## Users and Permissions

Linux is a multi-user operating system. Every process runs as a particular user
and every file is owned by a user and a group. The kernel uses numeric user IDs
(UIDs) and group IDs (GIDs) internally; usernames and group names are just
human-readable labels mapped through configuration files.

### Users and groups

Three files define users and groups on the system:

**`/etc/passwd`** — one line per user account:

```
dave:x:1000:1000:Dave Tang:/home/dave:/bin/bash
```

The fields (colon-separated) are:

1. Username
2. Password placeholder (`x` means the hash is in `/etc/shadow`)
3. UID
4. Primary GID
5. GECOS / comment (often the full name)
6. Home directory
7. Login shell

**`/etc/shadow`** — stores password hashes (readable only by root):

```
dave:$6$rounds=5000$salt$hash...:19500:0:99999:7:::
```

Key fields are the username, the hashed password, and password-aging parameters
(last changed, minimum age, maximum age, warning period).

**`/etc/group`** — one line per group:

```
sudo:x:27:dave,alice
```

Fields: group name, password placeholder, GID, comma-separated member list.

Use `id` to see who you are:

```console
id
# uid=1000(dave) gid=1000(dave) groups=1000(dave),27(sudo),44(video)

whoami
# dave

groups
# dave sudo video
```

### Managing users

```console
# Create a new user with a home directory and default shell
sudo useradd -m -s /bin/bash alice

# On Debian/Ubuntu, adduser is an interactive wrapper
sudo adduser alice

# Set or change a password
sudo passwd alice

# Modify an existing user — change their shell
sudo usermod -s /bin/zsh alice

# Lock an account (prefix the password hash with !)
sudo usermod -L alice

# Unlock it
sudo usermod -U alice

# Delete a user and their home directory
sudo userdel -r alice
```

**System users** (UIDs below 1000 on most distros) are used to run services.
They typically have no login shell and no home directory:

```console
sudo useradd -r -s /usr/sbin/nologin myservice
```

### Managing groups

```console
# Create a group
sudo groupadd developers

# Add a user to a supplementary group (-a = append, -G = supplementary)
sudo usermod -aG developers alice

# The change takes effect on next login; verify with
groups alice
# alice : alice developers

# Remove a user from a group (Debian/Ubuntu)
sudo deluser alice developers

# Delete a group
sudo groupdel developers
```

Every user has exactly one **primary group** (the GID in `/etc/passwd`). Files
created by that user are owned by the primary group by default. **Supplementary
groups** grant additional access and are listed in `/etc/group`.

### File permissions

Every file has an owner (user), a group, and a set of permission bits for three
classes: **owner (u)**, **group (g)**, and **other (o)**.

```console
ls -la /etc/shadow
# -rw-r----- 1 root shadow 1720 Jan 10 12:00 /etc/shadow
```

Breaking down `-rw-r-----`:

| Position | Meaning               |
|----------|-----------------------|
| `-`      | File type (`-` file, `d` directory, `l` symlink) |
| `rw-`    | Owner: read + write   |
| `r--`    | Group: read only      |
| `---`    | Other: no access      |

For directories, the bits have different meanings:

| Bit | File          | Directory                          |
|-----|---------------|------------------------------------|
| `r` | Read contents | List filenames                     |
| `w` | Modify        | Create/delete files in directory   |
| `x` | Execute       | Access (cd into) the directory     |

**chmod** — change permissions using octal or symbolic notation:

```console
# Octal: owner=rwx(7), group=r-x(5), other=r-x(5)
chmod 755 script.sh

# Symbolic: add execute for owner
chmod u+x script.sh

# Remove write for group and other
chmod go-w file.txt

# Set exact permissions for all classes
chmod u=rwx,g=rx,o= secret.sh
```

**chown** and **chgrp** — change ownership:

```console
# Change owner
sudo chown alice file.txt

# Change owner and group
sudo chown alice:developers file.txt

# Change group only
chgrp developers file.txt

# Recursively change ownership of a directory tree
sudo chown -R alice:developers /opt/project/
```

### Default permissions (umask)

The `umask` controls the default permissions for newly created files and
directories. It is a bitmask that is _subtracted_ from the maximum permissions
(666 for files, 777 for directories).

```console
umask
# 0022

# With umask 0022:
# New files:       666 - 022 = 644 (rw-r--r--)
# New directories: 777 - 022 = 755 (rwxr-xr-x)
```

Set a stricter umask (e.g., no access for "other"):

```console
umask 0027
# New files:       666 - 027 = 640 (rw-r-----)
# New directories: 777 - 027 = 750 (rwxr-x---)
```

To make the change permanent, add the `umask` command to `~/.bashrc` or
`~/.profile`. System-wide defaults are in `/etc/login.defs`.

### Special permission bits

Three additional bits modify the standard permission model:

**setuid (4xxx)** — when set on an executable, the process runs as the file's
_owner_ rather than the user who launched it. The classic example is `passwd`:

```console
ls -la /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 ... /usr/bin/passwd
```

The `s` in the owner execute position means setuid is set. This allows any user
to run `passwd` with root privileges so it can write to `/etc/shadow`.

**setgid (2xxx)** — on an executable, the process runs with the file's _group_.
On a directory, new files created inside inherit the directory's group rather
than the creator's primary group. Useful for shared project directories:

```console
# Create a shared directory
sudo mkdir /opt/shared
sudo chgrp developers /opt/shared
sudo chmod 2775 /opt/shared
# New files inside will belong to group "developers"
```

**Sticky bit (1xxx)** — on a directory, only the file owner (or root) can delete
or rename files inside, even if others have write permission. `/tmp` uses this:

```console
ls -ld /tmp
# drwxrwxrwt 15 root root 4096 ... /tmp
```

The `t` in the other execute position indicates the sticky bit.

Set special bits with chmod:

```console
# setuid
chmod u+s /usr/local/bin/myapp    # or chmod 4755

# setgid on a directory
chmod g+s /opt/shared             # or chmod 2775

# sticky bit
chmod +t /opt/shared              # or chmod 1777
```

### sudo

`sudo` allows permitted users to run commands as root (or another user). Its
configuration lives in `/etc/sudoers`, which should **always** be edited with
`visudo` (it validates syntax before saving).

```console
# Run a command as root
sudo systemctl restart nginx

# Run as a different user
sudo -u postgres psql

# List what the current user is allowed to do
sudo -l
```

Key `/etc/sudoers` patterns:

```
# Allow user dave to run any command as any user
dave    ALL=(ALL:ALL) ALL

# Allow the "deploy" group to restart nginx without a password
%deploy ALL=(root) NOPASSWD: /usr/bin/systemctl restart nginx

# Allow alice to run all commands but require a password each time
Defaults:alice timestamp_timeout=0
alice   ALL=(ALL:ALL) ALL
```

Drop custom rules into `/etc/sudoers.d/` rather than editing the main file
directly — `visudo -f /etc/sudoers.d/deploy` for example.

### SSH key authentication

Password-based SSH login is convenient but less secure than key-based
authentication. Keys use a public/private pair — the private key stays on
your machine, the public key goes on the server.

```console
# Generate a key pair (Ed25519 is recommended)
ssh-keygen -t ed25519 -C "dave@workstation"
# Generates: ~/.ssh/id_ed25519 (private) and ~/.ssh/id_ed25519.pub (public)

# Copy the public key to a remote server
ssh-copy-id user@server
# Or manually append to ~/.ssh/authorized_keys on the server
```

**Correct permissions are critical** — SSH will refuse to use keys with
overly permissive permissions:

```console
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519          # private key
chmod 644 ~/.ssh/id_ed25519.pub      # public key
chmod 600 ~/.ssh/authorized_keys     # on the server
```

Use `ssh-agent` to avoid re-entering the passphrase for every connection:

```console
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

To disable password login entirely (keys only), set in `/etc/ssh/sshd_config`:

```
PasswordAuthentication no
```

Then reload: `sudo systemctl reload sshd`.

### Access Control Lists (ACLs)

Standard Unix permissions only support one owner and one group per file. ACLs
extend this model, letting you grant access to additional users or groups
without changing ownership.

```console
# View the ACL on a file
getfacl project.txt
# # file: project.txt
# # owner: dave
# # group: dave
# user::rw-
# group::r--
# other::r--

# Grant read/write to alice specifically
setfacl -m u:alice:rw project.txt

# Grant read to the "qa" group
setfacl -m g:qa:r project.txt

# View the updated ACL
getfacl project.txt
# user::rw-
# user:alice:rw-
# group::r--
# group:qa:r--
# mask::rw-
# other::r--

# Remove alice's ACL entry
setfacl -x u:alice project.txt

# Remove all ACL entries (revert to standard permissions)
setfacl -b project.txt
```

When an ACL is present, `ls -l` shows a `+` after the permission bits:

```console
ls -l project.txt
# -rw-rw-r--+ 1 dave dave 1234 Jan 10 12:00 project.txt
```

Use `-R` for recursive operations and `-d` to set default ACLs on directories
(inherited by new files created inside):

```console
# New files in /opt/shared will give the qa group read access by default
setfacl -d -m g:qa:r /opt/shared
```

The filesystem must be mounted with ACL support (most modern distros enable this
by default for ext4 and xfs).
