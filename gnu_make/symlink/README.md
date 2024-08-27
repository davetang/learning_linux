# README

Use Make to create symlinks. Create one symlink, but keep different versions of underlying file as a backup.

```console
make
ls
```
```
20240827_145324  dep.txt  Makefile  my_symlink
```

```console
make
```
```
make: Nothing to be done for 'all'.
```

Modify `dep.txt`.

```console
printf "four\n" >> dep.txt
make
ls
```
```
20240827_145324  20240827_145614  dep.txt  Makefile  my_symlink
```
