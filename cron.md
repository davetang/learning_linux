# README

Some useful tidbits from the manual, i.e. `man`.

## Cron

On CentOS 7, use `yum list` to find which package of `cron` is installed.

```console
sudo yum list | grep -i cron
```

Get more info on the package.

```console
sudo yum info cronie.x86_64
```

This documentation is based `cronie` on x86_64 and version 1.4.11 and from `man
cron`.

Cron checks these files and directories:

* `/etc/crontab` - system crontab.  Nowadays the file is empty by default.
* `/etc/cron.d/` - directory that contains system cronjobs stored for different
  users.
* `/var/spool/cron` - directory that contains user crontables created by
  `crontab`.

All `crontab` files have to be regular files or symlinks to regular files, they
must not be executable or writable for anyone else but the owner. This
requirement can be overridden by using the -p option on the `crond` command
line. If `inotify` support is in use, changes in the symlinked `crontabs` are
not automatically noticed by the cron daemon. The cron daemon must receive a
SIGHUP signal to reload the crontabs. This is a limitation of the `inotify`
API.

The syslog output will be used instead of `mail`, when `sendmail` is not installed.

## Crontab

This documentation is based `cronie` on x86_64 and version 1.4.11 and from `man
cron`.

`crontab` is used to install a `crontab` table file, remove or list the
existing tables used to serve the `cron` daemon. Each user can have their own
`crontab`, and though these are files in `/var/spool/`, they are not intended
to be edited directly.

The temporary directory can be set in an environment variable. If it is not set
by the user, the `/tmp` directory is used.

We can check the `PATH` in a `cron` job but running the following.

```
* * * * * echo $(whoami) ${PATH} > ${HOME}/crontab_path.txt
```

`PATH` is limited to `/usr/bin:/bin`.

```console
cat ~/crontab_path.txt
# dtang /usr/bin:/bin
```

To modify the `PATH`, we can set `PATH` in the `crontab` file but using
variables when setting `PATH` **does not work**, i.e.
`PATH=${PATH}:${HOME}/bin`. Setting the PATH needs to be hardcoded.

```
PATH=/usr/bin:/bin:/home/dtang/bin
* * * * * echo $(whoami) ${PATH} > ${HOME}/crontab_path.txt
```

Check new `PATH`.

```console
cat ~/crontab_path.txt
# dtang /usr/bin:/bin:/home/dtang/bin
```

Let's check the shell used.

```
* * * * * echo ${SHELL} > ${HOME}/crontab_shell.txt
```

`/bin/sh` is used.

```console
cat ~/crontab_shell.txt
# /bin/sh
```

This can be changed by setting `SHELL`.

```
SHELL=/bin/bash
* * * * * echo ${SHELL} > ${HOME}/crontab_shell.txt
```

`/bin/bash` is used now.

```console
cat ~/crontab_shell.txt
# /bin/bash
```
