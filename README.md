# systemd-units

A collection of custom systemd units and generators


### Install

```
make install
```


### Uninstall

```
make uninstall
```

### Disable Units

Units need to have valid systemd-type extensions (`.service`, `.mount`, `.automount` etc.).

To disable a unit, simply rename it to an invalid extension, _e.g._

```sh
# Disable
mv mounts/mnt-samba-example.mount mounts/mnt-samba-example.mount.disabled

# Enable
mv mounts/mnt-samba-example.mount.disabled mounts/mnt-samba-example.mount
```

